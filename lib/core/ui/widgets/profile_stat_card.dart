import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

class ProfileStat {
  final String label;
  final String value;

  const ProfileStat({required this.label, required this.value});
}

/// Fileira horizontal de cards de estatística do app (dias de uso,
/// avaliações, denúncias...) usada no topo do perfil de consumidor e
/// comerciante. [stats] null enquanto os dados ainda carregam — mostra
/// placeholders no lugar do valor.
///
/// Cada card se dimensiona pelo próprio conteúdo (sem altura fixa) — um
/// `ListView` horizontal força a altura dos filhos a caber exatamente no
/// espaço do viewport, e um rótulo mais longo ("Denúncias Recebidas") ou
/// uma fonte de sistema maior (acessibilidade) estourava esse limite.
class ProfileStatsRow extends StatelessWidget {
  final List<ProfileStat>? stats;

  const ProfileStatsRow({super.key, required this.stats});

  static const _corFundo = Color(0xFFFBD98A);
  static const _skeletonCount = 3;

  @override
  Widget build(BuildContext context) {
    final items = stats;
    final count = items?.length ?? _skeletonCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int index = 0; index < count; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.sm),
            _buildCard(context, items?[index]),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, ProfileStat? stat) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 116.0, maxWidth: 160.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4.0),
        decoration: BoxDecoration(
          color: _corFundo,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stat?.label ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.legenda(context).copyWith(
                color: Colors.black.withValues(alpha: 0.65),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              stat?.value ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitulo(context).copyWith(
                fontSize: 22.0,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
