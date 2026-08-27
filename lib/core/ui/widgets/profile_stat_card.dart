import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class ProfileStat {
  final String label;
  final String value;
  final Color color;

  const ProfileStat({required this.label, required this.value, required this.color});
}

/// Fileira horizontal de cards de estatística do app (dias de uso,
/// avaliações, denúncias...) usada no topo do perfil de consumidor e
/// comerciante. [stats] null enquanto os dados ainda carregam — mostra
/// placeholders no lugar do valor.
///
/// Cada card tem sua própria cor de identidade (definida pelo caller, ver
/// `AppMetricColors`) em vez de um fundo único fixo — reforça a mesma lógica
/// de "cor carrega significado" da paleta por categoria (`category_colors.dart`),
/// e resolve de quebra a adaptação a dark mode (antes o card usava um hex
/// fixo em qualquer tema).
///
/// Cada card se dimensiona pelo próprio conteúdo (sem altura fixa) — um
/// `ListView` horizontal força a altura dos filhos a caber exatamente no
/// espaço do viewport, e um rótulo mais longo ("Denúncias Recebidas") ou
/// uma fonte de sistema maior (acessibilidade) estourava esse limite.
class ProfileStatsRow extends StatelessWidget {
  final List<ProfileStat>? stats;

  /// Inset horizontal do scroll — default pensado pra uso "full-bleed" (fora
  /// de qualquer container com padding próprio, como no Perfil). Zere isso
  /// quando a linha já estiver dentro de um container que já aplica esse
  /// mesmo espaçamento (ex: dashboard do comerciante), senão o padding soma
  /// em dobro.
  final double horizontalPadding;

  const ProfileStatsRow({super.key, required this.stats, this.horizontalPadding = Spacing.lg});

  static const _skeletonCount = 3;

  @override
  Widget build(BuildContext context) {
    final items = stats;
    final count = items?.length ?? _skeletonCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int index = 0; index < count; index++) ...[
            if (index > 0) const SizedBox(width: Spacing.sm),
            _buildCard(context, items?[index]),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProfileStat? stat) {
    // Skeleton (stat == null, dado ainda carregando): superfície neutra do
    // tema em vez de uma cor de identidade que ainda não se sabe qual é.
    final corFundo = stat?.color ?? context.mapColors.surface;
    final corTexto = stat != null ? Colors.white : context.mapColors.textSecondary;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 116.0, maxWidth: 160.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm + 4.0),
        decoration: BoxDecoration(
          color: corFundo,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: stat == null ? Border.all(color: context.mapColors.border) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stat?.label ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption(context).copyWith(
                color: corTexto.withValues(alpha: stat != null ? 0.85 : 1.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              stat?.value ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.h2(context).copyWith(
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
                color: corTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
