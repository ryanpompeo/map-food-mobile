import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/merchant/presentation/controllers/store_ronda_controller.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_status_card.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/widgets/store_map_view.dart';

class StoreOperationSection extends StatefulWidget {
  final StoreDto store;

  final ValueChanged<StoreDto>? onStoreUpdated;

  const StoreOperationSection({
    super.key,
    required this.store,
    this.onStoreUpdated,
  });

  @override
  State<StoreOperationSection> createState() => _StoreOperationSectionState();
}

class _StoreOperationSectionState extends State<StoreOperationSection> {
  late final StoreRondaController _ronda;

  @override
  void initState() {
    super.initState();
    _ronda = StoreRondaController(
      store: widget.store,
      onStoreUpdated: widget.onStoreUpdated,
    );
  }

  @override
  void didUpdateWidget(covariant StoreOperationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ronda.atualizarStore(widget.store);
  }

  @override
  void dispose() {
    _ronda.dispose();
    super.dispose();
  }

  Future<void> _alternar() async {
    final erro = await _ronda.alternarStatus();
    if (erro != null && mounted) AppToast.error(context, erro);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final alturaMapa = (MediaQuery.sizeOf(context).height * 0.34).clamp(220.0, 360.0);

    return ListenableBuilder(
      listenable: _ronda,
      builder: (context, _) {
        final aberta = _ronda.aberta;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: StoreStatusCard(
                aberta: aberta,
                rastreioAtivo: _ronda.rastreioAtivo,
                ocupado: _ronda.alternando,
                ultimaPosicaoEm: _ronda.ultimaPosicaoEm,
                precisaoMetros: _ronda.precisaoMetros,
                avisoPosicao: _ronda.avisoPosicao,
                onToggle: _alternar,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Onde você aparece', style: AppText.h2(context)),
                  const SizedBox(height: 2),
                  Text(
                    aberta
                        ? 'É este o ponto que os clientes veem no mapa.'
                        : 'Último ponto registrado. Abra a loja para voltar ao mapa.',
                    style: AppText.secondary(context).copyWith(height: 1.4),
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
                      child: StoreMapView(stores: [_ronda.store], focusedStore: _ronda.store),
                    ),
                    if (!aberta)
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
              child: _DicaRonda(aberta: aberta),
            ),
          ],
        );
      },
    );
  }
}

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
