import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_food/core/app_info.dart';
import 'package:map_food/core/session/session_manager.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/features/guest/presentation/pages/guest_home_page.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';

/// Tela dedicada de Configurações — antes estas opções (aparência,
/// permissões de GPS, excluir conta, como funciona, termos) viviam
/// achatadas no meio da lista do Perfil, junto de "Editar Perfil" e
/// "Minhas avaliações", misturando ajustes do app com atalhos de conteúdo.
///
/// Compartilhada entre consumidor e comerciante: o que muda entre os dois é
/// só a página de "Como funciona" e a chamada de exclusão de conta, ambas
/// injetadas por quem abre a tela.
class SettingsPage extends StatelessWidget {
  /// Exclui a conta no backend (DELETE /comerciantes|consumidores/{id}).
  /// `null` esconde o item "Excluir conta" — é o caso do comerciante hoje,
  /// enquanto o endpoint ainda falha com 409 por dependências não limpas
  /// (favoritos da loja, posts, pix). Voltar a passar a callback quando o
  /// backend fizer o cascade completo.
  final Future<void> Function()? onDeleteAccount;

  /// Hook extra no encerramento de sessão (ex: limpar favoritos do
  /// consumidor) — mesmo contrato do logout no Perfil.
  final VoidCallback? onLogoutExtra;

  final WidgetBuilder howItWorksPageBuilder;

  const SettingsPage({
    super.key,
    this.onDeleteAccount,
    required this.howItWorksPageBuilder,
    this.onLogoutExtra,
  });

  /// Mesmo fluxo que rodava no Perfil antes de "Excluir conta" migrar pra
  /// cá: confirma, apaga no backend, limpa a sessão local e o estado com
  /// escopo de usuário, e volta pra home de visitante sem histórico.
  Future<void> _excluirConta(BuildContext context) async {
    final excluir = onDeleteAccount;
    if (excluir == null) return;

    final confirmou = await confirmarExclusaoConta(context);
    if (!confirmou || !context.mounted) return;

    try {
      await excluir();
      await SessionStore.instance.signOut();
      SessionManager.clearUserScopedState();
      onLogoutExtra?.call();
      if (!context.mounted) return;
      unawaited(Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (context) => GuestHomePage()),
        (route) => false,
      ));
    } catch (_) {
      if (context.mounted) {
        AppToast.error(context, "Erro ao excluir a conta. Tente novamente.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.base),
              _buildHeader(context),
              const SizedBox(height: Spacing.xl),

              const MenuSectionLabel(label: "Aparência"),
              const SizedBox(height: Spacing.sm),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: ThemeModeSelector(),
              ),
              const SizedBox(height: Spacing.xl),

              const MenuSectionLabel(label: "Conta"),
              const SizedBox(height: Spacing.sm),
              MenuListTile(
                icon: AppIcons.mapPin,
                title: "Permissões de Localização",
                subtitle: "Gerenciar acesso ao GPS",
                onTap: () => Geolocator.openAppSettings(),
              ),
              if (onDeleteAccount != null)
                MenuListTile(
                  icon: AppIcons.trash,
                  title: "Excluir conta",
                  subtitle: "Apaga sua conta e dados permanentemente",
                  iconColor: ColorsPalette.redComponents,
                  iconBackgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.1),
                  onTap: () => _excluirConta(context),
                ),
              const SizedBox(height: Spacing.xl),

              const MenuSectionLabel(label: "Sobre"),
              const SizedBox(height: Spacing.sm),
              MenuListTile(
                icon: AppIcons.question,
                title: "Como funciona?",
                subtitle: "Veja como usar o MapFood",
                onTap: () => Navigator.push(context, appPageRoute(builder: howItWorksPageBuilder)),
              ),
              MenuListTile(
                icon: AppIcons.fileText,
                title: "Termos de Uso e Privacidade",
                subtitle: "Termos, privacidade e políticas",
                onTap: () => Navigator.push(context, appPageRoute(builder: (_) => const TermosPage())),
              ),

              const SizedBox(height: Spacing.xl),
              Center(
                child: Text('Versão $kAppVersion', style: AppText.caption(context)),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Row(
        children: [
          SemanticTapArea(
            label: 'Voltar',
            onTap: () => Navigator.maybePop(context),
            child: Container(
              // 44, não 40: era o único alvo de toque do app ainda abaixo do
              // mínimo. Icon-only, então não escala com a fonte — o que ele
              // precisava era do tamanho certo.
              height: 44.0,
              width: 44.0,
              decoration: BoxDecoration(
                color: context.mapColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents, size: AppIconSize.md),
            ),
          ),
          const SizedBox(width: Spacing.base),
          Text(
            "Configurações",
            style: AppText.h1(context).copyWith(
              color: context.mapColors.textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seletor de tema em pílula segmentada. Três opções, não duas: o modo
/// "Automático" é o padrão de quem nunca escolheu tema — um par
/// Claro/Escuro forçaria essas pessoas a sair dele sem querer.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  static const _options = [
    (mode: ThemeMode.light, label: "Claro", icon: AppIcons.sun),
    (mode: ThemeMode.dark, label: "Escuro", icon: AppIcons.moon),
    (mode: ThemeMode.system, label: "Auto", icon: AppIcons.deviceMobile),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: context.mapColors.surface,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      // Isolamento de rebuild: só o segmentado escuta o ThemeController —
      // o resto da tela de configurações não reconstrói a cada troca.
      child: ListenableBuilder(
        listenable: ThemeController.instance,
        builder: (context, _) {
          final current = ThemeController.instance.value;
          return Row(
            children: [
              for (final option in _options)
                Expanded(
                  // Segmentado: aqui o estado ativo não é só cor — o segmento
                  // escolhido ganha uma superfície que os outros não têm, e a
                  // presença desse bloco é perceptível sem distinguir matiz.
                  // Faltava só o nó de semântica com o "selecionado".
                  child: SemanticTapArea(
                    label: option.label,
                    selected: current == option.mode,
                    onTap: () => ThemeController.instance.setThemeMode(option.mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      // Segmento com rótulo dentro: altura mínima, não fixa —
                      // o seletor vive numa Column e tem para onde crescer.
                      constraints: const BoxConstraints(minHeight: 42.0),
                      decoration: BoxDecoration(
                        // `selectedSurface`: o mesmo "segmento ativo" do
                        // seletor de tipo de conta e dos chips de período —
                        // e que inverte no tema escuro, onde o preto da
                        // marca ficaria indistinguível do fundo.
                        color: current == option.mode
                            ? context.mapColors.selectedSurface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(Radii.xl),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option.icon,
                            size: AppIconSize.sm,
                            color: current == option.mode
                                ? context.mapColors.onSelectedSurface
                                : context.mapColors.textSecondary,
                          ),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: current == option.mode
                                    ? context.mapColors.onSelectedSurface
                                    : context.mapColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
