import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
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

  final _storeService = StoreService();

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _lojaAberta = widget.store.statusLoja == 'ATIVA';
    if (_lojaAberta) _iniciarRastreamento();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
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
    if (mounted) setState(() => _rastreioAtivo = false);
  }

  Future<void> _enviarNovaPosicao(Position posicao) async {
    final seq = ++_posicaoSeq;
    try {
      // PUT /lojas/{id} faz merge campo-a-campo no backend, então reenviar
      // nome/descricao/categorias existentes é seguro e não apaga os demais
      // dados da loja.
      final atualizada = await _storeService.update(
        _store.id,
        StoreCreateRequest(
          nome: _store.nome,
          descricao: _store.descricao,
          statusLoja: _store.statusLoja,
          categoriaIds: _store.categoriaIds,
          latitude: posicao.latitude,
          longitude: posicao.longitude,
        ),
      );
      // Descarta a resposta se uma posição mais recente já foi enviada
      // enquanto esta estava em voo — evita regredir a posição exibida.
      if (seq != _posicaoSeq) return;
      if (mounted) setState(() => _store = atualizada);
      widget.onStoreUpdated?.call(atualizada);
    } catch (_) {
      // Falha isolada de uma atualização de posição não interrompe o
      // rastreamento — a próxima tentativa (próximo deslocamento) resolve.
    }
  }

  Future<void> _toggleLojaStatus(bool val) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    try {
      final session = await AuthStorage.getSession();
      if (session == null) return;

      final novoStatus = val ? 'ATIVA' : 'INATIVA';
      // Endpoint aditivo da Fase 4 — troca só o status (o backend já
      // rejeitaria SUSPENSA vinda do mobile, embora este toggle nunca a envie).
      final atualizada = await _storeService.atualizarStatus(_store.id, novoStatus);

      if (mounted) {
        setState(() {
          _lojaAberta = val;
          _store = atualizada;
        });
      }
      widget.onStoreUpdated?.call(atualizada);

      if (val) {
        _iniciarRastreamento();
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
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(),
        title: Text(
          _store.nome,
          style: AppText.titulo(context).copyWith(
            fontWeight: FontWeight.w900,
            color: context.mapColors.primaryText,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.storeSwitcher != null) widget.storeSwitcher!,
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: SizedBox(width: double.infinity, child: _buildLojaStatusCard()),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              "Sua localização no mapa",
              style: AppText.subtitulo(
                context,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.mapColors.cardSurface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: StoreMapView(stores: [_store], focusedStore: _store),
            ),
          ),

          const SizedBox(height: 120.0),
        ],
      ),
    );
  }

  Widget _buildLojaStatusCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Aberta: card sólido preto de propósito, como um CTA (Lote 1).
        // Fechada: superfície neutra, adapta ao tema.
        color: _lojaAberta ? ColorsPalette.black : context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: _lojaAberta
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsRegular.storefront,
                    color: _lojaAberta ? Colors.white : context.mapColors.primaryText,
                  ),
                  if (_rastreioAtivo) ...[
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: ColorsPalette.redComponents,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.0,
                            height: 6.0,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            "AO VIVO",
                            style: AppText.legenda(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              _isUpdatingStatus
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _lojaAberta
                            ? Colors.white
                            : ColorsPalette.redComponents,
                      ),
                    )
                  : Switch(
                      value: _lojaAberta,
                      activeThumbColor: ColorsPalette.whiteBackground,
                      activeTrackColor: ColorsPalette.redComponents,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade200,
                      onChanged: _toggleLojaStatus,
                    ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _lojaAberta ? "Loja Aberta" : "Loja Fechada",
            style: AppText.corpo(context).copyWith(
              fontWeight: FontWeight.w800,
              color: _lojaAberta ? Colors.white : context.mapColors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _lojaAberta ? "Visível aos clientes" : "Invisível no mapa",
            // Aberta: cinza claro fixo, emparelhado com o card preto sólido
            // acima (que também não muda com o tema). Fechada: secondaryText.
            style: AppText.legenda(context).copyWith(
              color: _lojaAberta ? Colors.grey.shade400 : null,
            ),
          ),
        ],
      ),
    );
  }

}
