import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/location/location_service.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

/// Mapa de lojas próximas com filtro de raio ajustável, usado na aba
/// "Início" de guest, consumidor e comerciante. Mantém sua própria
/// assinatura de GPS (só em primeiro plano) pra atualizar a posição do
/// usuário conforme ele anda, recalculando quais lojas caem dentro do raio.
class NearbyStoresSection extends StatefulWidget {
  /// Lojas já filtradas por categoria pelo widget pai — este widget só
  /// aplica o filtro de distância por cima.
  final List<StoreDto> stores;
  final double? initialLatitude;
  final double? initialLongitude;

  const NearbyStoresSection({
    super.key,
    required this.stores,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<NearbyStoresSection> createState() => _NearbyStoresSectionState();
}

class _NearbyStoresSectionState extends State<NearbyStoresSection> {
  // km; null representa "Todos" (sem filtro de distância).
  static const List<double?> _raiosKm = [1.0, 5.0, 10.0, 20.0, null];

  double? _raioSelecionadoKm = 5.0;
  double? _lat;
  double? _lng;
  StreamSubscription<Position>? _positionSub;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLatitude;
    _lng = widget.initialLongitude;
    _iniciarRastreamento();
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

      if (_lat == null || _lng == null) {
        try {
          final posicao = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
          );
          if (mounted) setState(() { _lat = posicao.latitude; _lng = posicao.longitude; });
        } catch (_) {
          // Segue sem posição inicial — o mapa cai no fallback padrão.
        }
      }

      // Stream compartilhado com a ronda do comerciante — um único consumo
      // de GPS mesmo com as duas telas vivas no IndexedStack.
      _positionSub = LocationService.positionStream.listen((posicao) {
        if (mounted) setState(() { _lat = posicao.latitude; _lng = posicao.longitude; });
      });
    } catch (_) {
      // Sem GPS disponível — mapa mostra todas as lojas recebidas, sem filtro de raio.
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  List<StoreDto> get _lojasNoRaio {
    if (_raioSelecionadoKm == null || _lat == null || _lng == null) return widget.stores;
    final raioMetros = _raioSelecionadoKm! * 1000;
    return widget.stores.where((loja) {
      if (!loja.temLocalizacao) return false;
      final distancia = Geolocator.distanceBetween(_lat!, _lng!, loja.latitude!, loja.longitude!);
      return distancia <= raioMetros;
    }).toList();
  }

  String _labelRaio(double? km) => km == null ? 'Todos' : '${km.toInt()} km';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 36.0,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: _raiosKm.length,
            itemBuilder: (context, index) {
              final raio = _raiosKm[index];
              final bool isSelected = _raioSelecionadoKm == raio;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _raioSelecionadoKm = raio),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? ColorsPalette.redComponents : Colors.white,
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(color: isSelected ? ColorsPalette.redComponents : Colors.grey.shade300),
                    ),
                    child: Text(
                      _labelRaio(raio),
                      style: AppText.legenda(context).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: StoreMapView(
            stores: _lojasNoRaio,
            initialLatitude: _lat,
            initialLongitude: _lng,
            userLatitude: _lat,
            userLongitude: _lng,
          ),
        ),
      ],
    );
  }
}
