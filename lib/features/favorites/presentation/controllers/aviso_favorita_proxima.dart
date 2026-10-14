import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/location/perfil_localizacao.dart';
import 'package:map_food/core/notificacoes/avisos_da_loja.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/aviso_proximidade_storage.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class AvisoFavoritaProxima with WidgetsBindingObserver {
  AvisoFavoritaProxima({
    FavoritesManager? favoritos,
    Aviso? avisar,
    DateTime Function()? agora,
    Stream<Position> Function()? posicoes,
    this.raioMetros = 1000,
  })  : _favoritos = favoritos ?? FavoritesManager.instance,
        _avisar = avisar ?? AvisosDaLoja.favoritaPerto,
        _agora = agora ?? DateTime.now,
        _posicoes = posicoes ?? (() => LocationService.streamDe(PerfilLocalizacao.consumidor));

  static final AvisoFavoritaProxima instance = AvisoFavoritaProxima();

  final FavoritesManager _favoritos;
  final Aviso _avisar;
  final DateTime Function() _agora;
  final Stream<Position> Function() _posicoes;
  final double raioMetros;

  StreamSubscription<Position>? _assinatura;
  bool _observando = false;
  bool _avaliando = false;

  bool get ligado => _assinatura != null;

  void ligar() {
    if (!SessionStore.instance.isConsumidor || _assinatura != null) return;
    _observarCicloDeVida();
    _assinatura = _posicoes().listen(_aoMover, onError: (Object _) {});
  }

  void desligar() {
    _assinatura?.cancel();
    _assinatura = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ligar();
      return;
    }
    desligar();
  }

  void _aoMover(Position posicao) => unawaited(avaliar(posicao));

  @visibleForTesting
  Future<void> avaliar(Position posicao) async {
    if (_avaliando) return;
    _avaliando = true;
    try {
      final hoje = _diaDe(_agora());
      if (await AvisoProximidadeStorage.ultimoDia() == hoje) return;

      final perto = _maisPertoDentroDoRaio(posicao);
      if (perto == null) return;

      await AvisoProximidadeStorage.registrar(hoje, perto.loja.id);
      await _avisar(_mensagem(perto));
    } finally {
      _avaliando = false;
    }
  }

  _FavoritaPerto? _maisPertoDentroDoRaio(Position posicao) {
    _FavoritaPerto? melhor;
    for (final loja in _favoritos.favorites) {
      final latitude = loja.latitude;
      final longitude = loja.longitude;
      if (latitude == null || longitude == null) continue;
      if (loja.status != StatusLoja.ativa) continue;

      final metros = Geolocator.distanceBetween(
        posicao.latitude,
        posicao.longitude,
        latitude,
        longitude,
      );
      if (metros > raioMetros) continue;
      if (melhor == null || metros < melhor.metros) {
        melhor = _FavoritaPerto(loja, metros);
      }
    }
    return melhor;
  }

  static String _mensagem(_FavoritaPerto perto) {
    final metros = perto.metros.round();
    final distancia = metros >= 1000
        ? '${(metros / 1000).toStringAsFixed(1)} km'
        : '$metros m';
    return '${perto.loja.nome} está a $distancia de você agora.';
  }

  static String _diaDe(DateTime quando) =>
      '${quando.year}-${quando.month.toString().padLeft(2, '0')}-${quando.day.toString().padLeft(2, '0')}';

  void _observarCicloDeVida() {
    if (_observando) return;
    WidgetsBinding.instance.addObserver(this);
    _observando = true;
  }
}

class _FavoritaPerto {
  final StoreDto loja;
  final double metros;

  const _FavoritaPerto(this.loja, this.metros);
}
