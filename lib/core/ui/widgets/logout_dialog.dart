import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_manager.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/guest/presentation/pages/guest_home_page.dart';

/// Confirmação de "Sair da conta" — extraída do `ProfilePageScaffold` quando
/// o perfil do consumidor deixou de usar aquele scaffold: os dois perfis
/// precisam encerrar sessão exatamente do mesmo jeito, e duplicar este fluxo
/// é como o `FavoritesManager` já vazou dados de uma conta pra outra antes.
///
/// [onLogoutExtra] é o hook opcional de quem chama (ex: limpar favoritos);
/// a limpeza de sessão e do estado com escopo de usuário roda sempre.
void mostrarDialogoLogout(BuildContext context, {VoidCallback? onLogoutExtra}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        backgroundColor: context.mapColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: ColorsPalette.redComponents.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      AppIcons.signOut,
                      color: ColorsPalette.redComponents,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    "Sair da conta",
                    style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Deseja realmente sair?",
                style: AppText.corpo(context).copyWith(color: context.mapColors.primaryText),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: ColorsPalette.transparent,
                      surfaceTintColor: ColorsPalette.transparent,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancelar",
                      style: AppText.botao(context).copyWith(color: context.mapColors.secondaryText),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    // backgroundColor/foregroundColor ficam de propósito
                    // como literais: é um CTA sólido preto/branco que deve
                    // parecer o mesmo nos dois temas, não uma superfície
                    // que se adapta ao brightness.
                    onPressed: () async {
                      // signOut (não AuthStorage.clear direto): limpa disco e
                      // memória de uma vez. Só limpar o disco deixava o
                      // SessionStore publicando um usuário já deslogado.
                      await SessionStore.instance.signOut();
                      // Sempre roda, pros dois papéis — não depende de a
                      // tela chamadora lembrar de passar onLogoutExtra
                      // (foi exatamente esse esquecimento, no perfil do
                      // comerciante, que deixava FavoritesManager vazando
                      // dados de uma conta pra outra no mesmo aparelho).
                      SessionManager.clearUserScopedState();
                      onLogoutExtra?.call();
                      if (!context.mounted) return;
                      unawaited(Navigator.pushAndRemoveUntil(
                        context,
                        appPageRoute(builder: (context) => GuestHomePage()),
                        (route) => false,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.black,
                      foregroundColor: ColorsPalette.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    ),
                    child: const Text("Sair", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
