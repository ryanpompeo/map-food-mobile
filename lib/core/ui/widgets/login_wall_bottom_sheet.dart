import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class LoginWallHelper {
  /// Sheet de "precisa de conta pra isso". Os textos são parametrizados
  /// porque a mesma parede agora barra três ações diferentes (favoritar,
  /// avaliar, denunciar) — anunciar "Salve seus comércios favoritos!" para
  /// quem tocou em "Denunciar" não explica nada. Os defaults são os textos
  /// originais de favoritos, então quem já chamava sem argumentos continua
  /// vendo exatamente o mesmo sheet.
  static void showLoginWallBottomSheet(
    BuildContext context, {
    IconData icon = AppIcons.heart,
    String title = "Salve seus comércios favoritos!",
    String description =
        "Crie uma conta gratuita em segundos para salvar, avaliar e denunciar comércios na sua cidade.",
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: bc.mapColors.cardSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl + MediaQuery.of(bc).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: bc.mapColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: ColorsPalette.redComponents,
                    size: 32.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppText.subtitulo(context).copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.mapColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: context.mapColors.secondaryText, height: 1.3),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Criar Conta Gratuita',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.accountType);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SemanticTapArea(
                  label: 'Já tenho uma conta',
                  hint: 'Abre a tela de entrar',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      "Já tenho uma conta",
                      style: AppText.legenda(context).copyWith(
                        color: context.mapColors.primaryText,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        );
      },
    );
  }
}
