import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_status_card.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

class MerchantWorkingPage extends StatefulWidget {
  final StoreDto store;

  /// Barra de troca de loja (comerciante com mais de uma loja) — opcional,
  /// renderizada como topo do body pra não colidir com o AppBar.
  final Widget? storeSwitcher;

  /// Notifica o pai quando a loja é alterada no backend (toggle de status,
  /// posição da ronda), pra lista de lojas dele não ficar defasada.
  final ValueChanged<StoreDto>? onStoreUpdated;

  const MerchantWorkingPage({
    super.key,
    required this.store,
    this.storeSwitcher,
    this.onStoreUpdated,
  });

  @override
  State<MerchantWorkingPage> createState() => _MerchantWorkingPageState();
}

class _MerchantWorkingPageState extends State<MerchantWorkingPage> {
  late bool _lojaAberta;
  bool _isUpdatingStatus = false;
  late StoreDto _store;

  // Assinatura de GPS que atualiza a lat/lng da loja em tempo real enquanto
  // ela está aberta ("Em Ronda") — só em primeiro plano, cancelada ao
  // fechar a loja ou sair da tela.
  StreamSubscription<Position>? _positionSub;
  bool _rastreioAtivo = false;
  // Incrementado a cada posição recebida — usado pra descartar a resposta de
  // um PUT antigo que chegue depois de um mais recente (rede lenta +
  // deslocamento rápido podem inverter a ordem de chegada das respostas).
  int _posicaoSeq = 0;

  /// Momento em que o servidor aceitou a última posição, e a precisão do fix
  /// que o aparelho reportou. Alimentam o rodapé do card de status: "aberta"
  /// e "sendo localizada" são estados diferentes, e antes não havia nada na
  /// tela que distinguisse os dois.
  DateTime? _ultimaPosicaoEm;
  double? _precisaoMetros;

  /// Falha corrente do envio de posição. Existe porque o `catch` mudo do
  /// envio deixava a loja parecendo "ao vivo" enquanto o servidor seguia com
  /// uma posição velha — o pior tipo de erro, o que não aparece.
  String? _avisoPosicao;

  /// Redesenha o "há X min" sem esperar uma nova posição chegar.
  Timer? _tickRelogio;

  final _storeService = StoreService();

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _lojaAberta = widget.store.statusLoja == 'ATIVA';
    if (_lojaAberta) _iniciarRastreamento();
  }

  @override
  void didUpdateWidget(covariant MerchantWorkingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resincroniza com a versão mais recente vinda do pai (ex: edição salva
    // na aba "Perfil da Loja") — sem isso, esta página seguia com o `_store`
    // capturado no `initState` e o próximo tick de GPS reenviava nome/
    // descrição/categorias desatualizados por cima da edição recém-salva,
    // já que esta tela fica viva em segundo plano (IndexedStack) enquanto
    // o comerciante navega para outra aba.
    if (widget.store.id == _store.id) _store = widget.store;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _tickRelogio?.cancel();
    super.dispose();
  }

  /// Um tick por minuto, e só enquanto a ronda está ligada: é a granularidade
  /// que o rótulo mostra ("agora", "há 3 min"). Um timer de segundos gastaria
  /// bateria pra reescrever o mesmo texto.
  void _iniciarRelogio() {
    _tickRelogio?.cancel();
    _tickRelogio = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _iniciarRastreamento() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      // O diálogo de permissão do SO pode levar segundos — se a tela já foi
      // fechada nesse meio-tempo, não assina o stream (senão a subscription
      // nunca é cancelada e o GPS fica ligado à toa).
      if (!mounted) return;
      setState(() => _rastreioAtivo = true);
      _iniciarRelogio();

      // Stream compartilhado com o mapa de lojas próximas — um único consumo
      // de GPS mesmo com as duas telas vivas no IndexedStack.
      _positionSub = LocationService.positionStream.listen(_enviarNovaPosicao);
    } catch (_) {
      // Sem GPS disponível — loja segue aberta, só sem posição ao vivo.
    }
  }

  void _pararRastreamento() {
    _positionSub?.cancel();
    _positionSub = null;
    _tickRelogio?.cancel();
    _tickRelogio = null;
    if (mounted) {
      setState(() {
        _rastreioAtivo = false;
        _ultimaPosicaoEm = null;
        _precisaoMetros = null;
        _avisoPosicao = null;
      });
    }
  }

  /// Busca uma posição atual pontual (não o stream) — usada pra exigir
  /// localização antes de deixar a loja ir pra ATIVA. Retorna `null` em
  /// qualquer falha (serviço desligado, permissão negada, timeout, sem
  /// fix de GPS): quem chama decide como bloquear a ativação nesse caso.
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

  Future<void> _enviarNovaPosicao(Position posicao) async {
    final seq = ++_posicaoSeq;
    try {
      // O payload completo é montado por `StoreCreateRequest.fromStore`, no
      // model — a tela não decide mais o que vai no corpo do PUT. Isso também
      // corrige a omissão de endereco/cidade/estado/cep, que este método
      // reenviava vazios a cada tick de GPS.
      final atualizada = await _storeService.atualizarPosicao(
        _store,
        posicao.latitude,
        posicao.longitude,
      );
      // Descarta a resposta se uma posição mais recente já foi enviada
      // enquanto esta estava em voo — evita regredir a posição exibida.
      if (seq != _posicaoSeq) return;
      if (mounted) {
        setState(() {
          _store = atualizada;
          _ultimaPosicaoEm = DateTime.now();
          _precisaoMetros = posicao.accuracy;
          _avisoPosicao = null;
        });
      }
      widget.onStoreUpdated?.call(atualizada);
    } catch (_) {
      // Uma falha isolada não interrompe o rastreamento — a próxima
      // tentativa (próximo deslocamento) resolve. Mas fica visível: sem
      // isso, o comerciante não tem como saber que parou de subir.
      if (seq == _posicaoSeq && mounted) {
        setState(() {
          _avisoPosicao =
              'Sua posição não está subindo. Verifique a conexão — no mapa dos '
              'clientes você continua no último ponto enviado.';
        });
      }
    }
  }

  Future<void> _alternarStatus() async {
    if (_isUpdatingStatus) return;
    final abrir = !_lojaAberta;
    setState(() => _isUpdatingStatus = true);

    try {
      // Guard de sessão: leitura síncrona do SessionStore (o id não é usado
      // aqui — a API extrai o comerciante do JWT nesta rota).
      if (SessionStore.instance.isGuest) return;

      StoreDto atualizada;
      if (abrir) {
        // Exige localização pra abrir a loja: sem coordenada, ela fica
        // ATIVA no banco mas invisível no mapa (o filtro de "perto de você"
        // ignora loja sem lat/long) — bloqueia aqui em vez de deixar esse
        // estado fantasma acontecer de novo.
        final posicao = await _obterPosicaoAtual();
        if (posicao == null) {
          if (mounted) {
            AppToast.error(
              context,
              'Não foi possível obter sua localização. Ative o GPS e permita o acesso pra abrir a loja.',
            );
          }
          return;
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
        if (mounted) {
          setState(() {
            _ultimaPosicaoEm = DateTime.now();
            _precisaoMetros = posicao.accuracy;
            _avisoPosicao = null;
          });
        }
      } else {
        // Fechar não precisa de localização — troca só o status, partindo do
        // estado que esta tela já tem (o backend rejeita SUSPENSA vinda do
        // mobile, embora este toggle nunca a envie).
        atualizada = await _storeService.atualizarStatus(_store, 'INATIVA');
      }

      if (mounted) {
        setState(() {
          _lojaAberta = abrir;
          _store = atualizada;
        });
      }
      widget.onStoreUpdated?.call(atualizada);

      if (abrir) {
        // Sem await: a ronda é um fluxo de longa duração (permissão + stream),
        // e o `finally` abaixo precisa liberar `_isUpdatingStatus` assim que o
        // status já foi persistido. Erros de GPS são tratados lá dentro.
        unawaited(_iniciarRastreamento());
      } else {
        _pararRastreamento();
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Erro ao alterar status da loja.');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    // Altura proporcional com piso e teto: o mapa é conferência ("estou
    // aparecendo onde acho que estou?"), não a tela principal — num aparelho
    // pequeno ele cede espaço para o card de status, que é o que se opera.
    final alturaMapa = (MediaQuery.sizeOf(context).height * 0.34).clamp(220.0, 360.0);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: Spacing.lg,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Minha operação',
              style: AppText.caption(context),
            ),
            Text(
              _store.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.h2(context),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (widget.storeSwitcher != null) ...[
            widget.storeSwitcher!,
            const SizedBox(height: Spacing.base),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: StoreStatusCard(
              aberta: _lojaAberta,
              rastreioAtivo: _rastreioAtivo,
              ocupado: _isUpdatingStatus,
              ultimaPosicaoEm: _ultimaPosicaoEm,
              precisaoMetros: _precisaoMetros,
              avisoPosicao: _avisoPosicao,
              onToggle: _alternarStatus,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Onde você aparece', style: AppText.h2(context)),
                      const SizedBox(height: 2),
                      Text(
                        _lojaAberta
                            ? 'É este o ponto que os clientes veem no mapa.'
                            : 'Último ponto registrado. Abra a loja para voltar ao mapa.',
                        style: AppText.secondary(context).copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Container(
              height: alturaMapa,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(color: colors.border),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: StoreMapView(stores: [_store], focusedStore: _store),
                  ),
                  // Loja fechada: véu sobre a cartografia. O mapa continua
                  // legível (é a referência do último ponto), mas para de
                  // parecer o estado ao vivo que ele não é.
                  if (!_lojaAberta)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.background.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.base),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _DicaRonda(aberta: _lojaAberta),
          ),
          // Respiro final: o conteúdo termina acima da bottom bar flutuante.
          const SizedBox(height: AppBottomBar.reservedSpace + Spacing.base),
        ],
      ),
    );
  }
}

/// Nota de rodapé explicando a ronda. Curta e presente nos dois estados: é a
/// única explicação de por que a loja "anda" no mapa, e some do caminho de
/// quem já sabe (uma linha, sem caixa colorida chamando atenção).
class _DicaRonda extends StatelessWidget {
  final bool aberta;

  const _DicaRonda({required this.aberta});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            aberta ? AppIcons.navigationArrow : AppIcons.info,
            size: AppIconSize.md,
            color: colors.textSecondary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              aberta
                  ? 'Enquanto a loja estiver aberta e este app em primeiro plano, sua '
                      'posição no mapa acompanha o seu deslocamento.'
                  : 'Ao abrir a loja, sua posição passa a ser atualizada automaticamente '
                      'conforme você se movimenta.',
              style: AppText.secondary(context).copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
