import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/storage/onboarding_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _destaques = [
    (icon: AppIcons.mapPin, texto: 'Veja quem está vendendo perto de você'),
    (icon: AppIcons.navigationArrow, texto: 'Acompanhe a rota em tempo real'),
    (icon: AppIcons.star, texto: 'Avalie e salve seus favoritos'),
  ];

  Future<void> _continuarSemConta(BuildContext context) async {
    await OnboardingStorage.marcarVisto();
    if (!context.mounted) return;
    unawaited(Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.root, (route) => false));
  }

  Future<void> _comecar(BuildContext context) async {
    await OnboardingStorage.marcarVisto();
    if (!context.mounted) return;
    unawaited(Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.root, (route) => false));
    unawaited(Navigator.pushNamed(context, AppRoutes.accountType));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xl, Spacing.lg, Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              Container(
                height: escalaComTeto(context, 60),
                width: escalaComTeto(context, 60),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Image.asset(
                    'assets/images/app_icon_copy.png',
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              Text('Comida de rua,\nperto de você', style: AppText.display(context)),
              const SizedBox(height: Spacing.md),
              Text(
                'Encontre comerciantes ambulantes em tempo real e descubra quem está em rota agora.',
                style: AppText.body(context).copyWith(color: colors.textSecondary),
              ),

              const SizedBox(height: Spacing.xxl),

              for (final destaque in _destaques) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.base),
                  child: Row(
                    children: [
                      Icon(destaque.icon, size: AppIconSize.md, color: MfColor.brand),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          destaque.texto,
                          style: AppText.body(context).copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 3),

              AppButton(
                label: 'Começar',
                icon: AppIcons.arrowRight,
                onPressed: () => _comecar(context),
              ),
              const SizedBox(height: Spacing.sm),
              AppButton(
                label: 'Continuar sem conta',
                variant: AppButtonVariant.ghost,
                onPressed: () => _continuarSemConta(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
