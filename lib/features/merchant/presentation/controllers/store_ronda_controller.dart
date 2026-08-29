import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

/// A operação da loja: abrir/fechar e manter a posição no mapa enquanto aberta.
///
/// Saiu sem reescrita da antiga aba "Ronda" — o comportamento de GPS é o
/// mesmo, linha por linha. O que muda é o dono: a lógica de rastreamento
/// deixou de morar num `State` de tela, e por isso sobreviveu à fusão daquela
/// aba com o painel de gestão (`MerchantStorePage`).
class StoreRondaController extends ChangeNotifier {
  StoreRondaController({
    required StoreDto store,
    this.onStoreUpdated,
    StoreService? storeService,
  })  : _store = store,
        _aberta = store.statusLoja == 'ATIVA',
        _storeService = storeService ?? StoreService() {
    if (_aberta) unawaited(iniciarRastreamento());
  }

  final StoreService _storeService;

  /// Avisa quem hospeda esta seção que a loja mudou no backend (status ou
  /// posição), para a lista de lojas dele não ficar defasada.
  final ValueChanged<StoreDto>? onStoreUpdated;

  StoreDto _store;
  StoreDto get store => _store;

  bool _aberta;
  bool get aberta => _aberta;

  bool _alternando = false;
  bool get alternando => _alternando;

  bool _rastreioAtivo = false;
  bool get rastreioAtivo => _rastreioAtivo;

  /// Momento em que o servidor aceitou a última posição, e a precisão do fix
  /// que o aparelho reportou. "Aberta" e "sendo localizada" são estados
  /// diferentes, e o rodapé do card de status precisa distinguir os dois.
  DateTime? _ultimaPosicaoEm;
  DateTime? get ultimaPosicaoEm => _ultimaPosicaoEm;

  double? _precisaoMetros;
  double? get precisaoMetros => _precisaoMetros;

  /// Falha corrente do envio de posição. Existe porque um `catch` mudo deixava
  /// a loja parecendo "ao vivo" enquanto o servidor seguia com uma posição
  /// velha — o pior tipo de erro, o que não aparece.
  String? _avisoPosicao;
  String? get avisoPosicao => _avisoPosicao;

  /// Assinatura de GPS que atualiza a lat/lng da loja em tempo real enquanto
  /// ela está aberta — só em primeiro plano, cancelada ao fechar ou sair.
  StreamSubscription<Position>? _positionSub;

  /// Incrementado a cada posição recebida — descarta a resposta de um PUT
  /// antigo que chegue depois de um mais recente (rede lenta + deslocamento
  /// rápido podem inverter a ordem de chegada).
  int _posicaoSeq = 0;

  /// Redesenha o "há X min" sem esperar uma nova posição chegar.
  Timer? _tickRelogio;

  bool _descartado = false;

  /// Resincroniza com a versão mais recente vinda de fora (ex: edição salva em
  /// outra tela). Sem isso, o próximo tick de GPS reenviaria nome/descrição/
  /// categorias desatualizados por cima da edição recém-salva — esta seção
  /// fica viva em segundo plano no `IndexedStack`.
  ///
  /// Loja **diferente** (switcher do comerciante) não é resync, é troca de
  /// alvo: delega para [trocarLoja]. Antes, o `return` mudo deste guard fazia
  /// a seção continuar operando a loja anterior — o card e o mapa não
  /// acompanhavam o switcher, e "Fechar loja" fechava a loja de antes.
  void atualizarStore(StoreDto store) {
    if (store.id != _store.id) {
      trocarLoja(store);
      return;
    }
    _store = store;
    final aberta = store.statusLoja == 'ATIVA';
    if (aberta != _aberta) {
      _aberta = aberta;
      // A loja pode ser fechada fora deste card (ex: "Inativar loja" em
      // Configurações avançadas). Sem desligar a ronda aqui, o GPS seguiria
      // ligado e enviando posição de uma loja que não está mais no mapa.
      if (!aberta) pararRastreamento();
    }
    _notificar();
  }

  /// Passa a operar **outra** loja (troca no switcher do comerciante).
  ///
  /// A ronda é sempre de uma loja só — a pessoa está num lugar de cada vez —,
  /// então a assinatura de GPS em curso, que estava enviando posição para a
  /// loja anterior, cai antes de qualquer coisa. `_posicaoSeq` avança junto
  /// para descartar um PUT da loja antiga que ainda esteja em voo: sem isso,
  /// a resposta atrasada devolveria `_store` para a loja de antes.
  void trocarLoja(StoreDto store) {
    if (store.id == _store.id) return;

    pararRastreamento();
    _posicaoSeq++;
    _store = store;
    _aberta = store.statusLoja == 'ATIVA';
    _notificar();

    // A loja recém-selecionada já estava aberta: a ronda segue nela, agora.
    if (_aberta) unawaited(iniciarRastreamento());
  }

  /// Um tick por minuto, e só enquanto a ronda está ligada: é a granularidade
  /// do rótulo ("agora", "há 3 min"). Um timer de segundos gastaria bateria
  /// para reescrever o mesmo texto.
  void _iniciarRelogio() {
    _tickRelogio?.cancel();
    _tickRelogio = Timer.periodic(const Duration(minutes: 1), (_) => _notificar());
  }

  Future<void> iniciarRastreamento() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      // O diálogo de permissão do SO pode levar segundos — se a seção já foi
      // descartada nesse meio-tempo, não assina o stream (senão a subscription
      // nunca é cancelada e o GPS fica ligado à toa).
      if (_descartado) return;
      _rastreioAtivo = true;
      _notificar();
      _iniciarRelogio();

      // Stream compartilhado com o mapa de lojas próximas — um único consumo
      // de GPS mesmo com as duas telas vivas no IndexedStack.
      _positionSub = LocationService.positionStream.listen(_enviarNovaPosicao);
    } catch (_) {
      // Sem GPS disponível — loja segue aberta, só sem posição ao vivo.
    }
  }

  void pararRastreamento() {
    _positionSub?.cancel();
    _positionSub = null;
    _tickRelogio?.cancel();
    _tickRelogio = null;
    _rastreioAtivo = false;
    _ultimaPosicaoEm = null;
    _precisaoMetros = null;
    _avisoPosicao = null;
    _notificar();
  }

  Future<void> _enviarNovaPosicao(Position posicao) async {
    final seq = ++_posicaoSeq;
    try {
      // O payload completo é montado por `StoreCreateRequest.fromStore`, no
      // model — a camada de tela não decide o que vai no corpo do PUT.
      final atualizada = await _storeService.atualizarPosicao(
        _store,
        posicao.latitude,
        posicao.longitude,
      );
      // Descarta a resposta se uma posição mais recente já foi enviada
      // enquanto esta estava em voo — evita regredir a posição exibida.
      if (seq != _posicaoSeq || _descartado) return;
      _store = atualizada;
      _ultimaPosicaoEm = DateTime.now();
      _precisaoMetros = posicao.accuracy;
      _avisoPosicao = null;
      _notificar();
      onStoreUpdated?.call(atualizada);
    } catch (_) {
      // Uma falha isolada não interrompe o rastreamento — a próxima tentativa
      // (próximo deslocamento) resolve. Mas fica visível: sem isso, o
      // comerciante não tem como saber que parou de subir.
      if (seq != _posicaoSeq || _descartado) return;
      _avisoPosicao = 'Sua posição não está subindo. Verifique a conexão — no mapa dos '
          'clientes você continua no último ponto enviado.';
      _notificar();
    }
  }

  /// Abre ou fecha a loja. Devolve `null` quando deu certo, ou a mensagem de
  /// erro para quem chamou exibir — o controller não conhece `BuildContext`,
  /// e toast é decisão de quem está na tela.
  Future<String?> alternarStatus() async {
    if (_alternando) return null;
    final abrir = !_aberta;
    // Loja alvo no momento do toque: abrir exige GPS, o que pode demorar
    // segundos, e nesse meio-tempo o switcher pode ter mudado de loja. Sem
    // guardar o alvo, a resposta aplicaria o status da loja A sobre a B.
    final alvoId = _store.id;

    _alternando = true;
    _notificar();

    try {
      // Guard de sessão: leitura síncrona do SessionStore (o id não é usado
      // aqui — a API extrai o comerciante do JWT nesta rota).
      if (SessionStore.instance.isGuest) return null;

      StoreDto atualizada;
      Position? posicaoAberta;
      if (abrir) {
        // Exige localização para abrir: sem coordenada, a loja fica ATIVA no
        // banco mas invisível no mapa (o filtro de "perto de você" ignora loja
        // sem lat/long) — bloqueia aqui em vez de deixar esse estado fantasma
        // acontecer de novo.
        final posicao = await _obterPosicaoAtual();
        if (posicao == null) {
          return 'Não foi possível obter sua localização. Ative o GPS e permita '
              'o acesso pra abrir a loja.';
        }
        atualizada = await _storeService.update(
          _store.id,
          StoreCreateRequest.fromStore(
            _store,
            statusLoja: 'ATIVA',
            latitude: posicao.latitude,
            longitude: posicao.longitude,
          ),
        );
        posicaoAberta = posicao;
      } else {
        // Fechar não precisa de localização — troca só o status, partindo do
        // estado que já temos (o backend rejeita SUSPENSA vinda do mobile,
        // embora este toggle nunca a envie).
        atualizada = await _storeService.atualizarStatus(_store, 'INATIVA');
      }

      if (_descartado) return null;

      // Trocou de loja enquanto a chamada estava em voo: o status foi gravado
      // na loja certa no servidor, e a lista de quem hospeda precisa saber —
      // mas escrever esse resultado no estado desta seção, que agora exibe
      // outra loja, é o que fazia "fechar a loja A" aparecer como a B fechada.
      if (alvoId != _store.id) {
        onStoreUpdated?.call(atualizada);
        return null;
      }

      if (posicaoAberta != null) {
        _ultimaPosicaoEm = DateTime.now();
        _precisaoMetros = posicaoAberta.accuracy;
        _avisoPosicao = null;
      }

      _aberta = abrir;
      _store = atualizada;
      _notificar();
      onStoreUpdated?.call(atualizada);

      if (abrir) {
        // Sem await: a ronda é um fluxo de longa duração (permissão + stream),
        // e o `finally` precisa liberar `alternando` assim que o status já foi
        // persistido. Erros de GPS são tratados lá dentro.
        unawaited(iniciarRastreamento());
      } else {
        pararRastreamento();
      }
      return null;
    } catch (_) {
      return 'Erro ao alterar status da loja.';
    } finally {
      _alternando = false;
      _notificar();
    }
  }

  /// Posição pontual (não o stream) — exigida antes de deixar a loja ir para
  /// ATIVA. `null` em qualquer falha: serviço desligado, permissão negada,
  /// timeout ou sem fix de GPS.
  Future<Position?> _obterPosicaoAtual() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 10));
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 10));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 10));
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {
      return null;
    }
  }

  void _notificar() {
    if (_descartado) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _positionSub?.cancel();
    _tickRelogio?.cancel();
    super.dispose();
  }
}
