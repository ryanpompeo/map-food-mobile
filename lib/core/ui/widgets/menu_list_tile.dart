import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';

/// Linha de menu do app (ícone em quadrado arredondado + título/subtítulo +
/// caret vermelho) — o mesmo item aparece no Perfil, nas Configurações e no
/// perfil de visitante, e existia copiado em cada um deles.
class MenuListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Cor de destaque opcional (ex: vermelho pra "Excluir conta") — null usa
  /// o tratamento neutro padrão da lista.
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const MenuListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        // A linha não tem altura fixa — cresce com o texto. O que faltava era
        // o alinhamento: com o título ocupando duas linhas em escala alta,
        // `center` (o padrão) deixava o ícone boiando no meio do bloco.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: escalaIcone(context, AppIconSize.lg),
                color: iconColor ?? context.mapColors.primaryText,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.corpo(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: iconColor ?? context.mapColors.primaryText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2.0),
                    Text(subtitle!, style: AppText.legenda(context)),
                  ],
                ],
              ),
            ),
            // O caret é decorativo e fica na ponta da linha: escala com teto
            // menor que os demais, para não roubar largura do título.
            Icon(
              AppIcons.caretRight,
              size: escalaIcone(context, AppIconSize.sm, teto: 1.3),
              color: ColorsPalette.redComponents.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rótulo de seção em caixa alta usado acima de grupos de [MenuListTile].
class MenuSectionLabel extends StatelessWidget {
  final String label;

  const MenuSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            fontSize: 11.0,
          ),
        ),
      ),
    );
  }
}
