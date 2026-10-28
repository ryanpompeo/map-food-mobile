import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/presentation/controllers/active_stores_manager.dart';

String textoDeDadosAntigos(Duration? idade) {
  if (idade == null) return 'Sem conexão · o mapa pode estar desatualizado';
  final minutos = idade.inMinutes;
  if (minutos < 1) return 'Sem conexão · mapa de agora há pouco';
  if (minutos < 60) return 'Sem conexão · mapa de $minutos min atrás';
  final horas = idade.inHours;
  return 'Sem conexão · mapa de $horas h atrás';
}

class FaixaSemConexao extends StatelessWidget {
  const FaixaSemConexao({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ActiveStoresManager.instance,
      builder: (context, filho) {
        final manager = ActiveStoresManager.instance;
        if (!manager.semConexao) return const SizedBox.shrink();
        return FaixaDeDadosAntigos(texto: textoDeDadosAntigos(manager.idadeDosDados));
      },
    );
  }
}

class FaixaDeDadosAntigos extends StatelessWidget {
  final String texto;

  const FaixaDeDadosAntigos({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.warning, size: AppIconSize.sm, color: colors.textSecondary),
            const SizedBox(width: Spacing.sm),
            Flexible(
              child: Text(
                texto,
                style: AppText.caption(context).copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
