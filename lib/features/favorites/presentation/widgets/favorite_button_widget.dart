import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

/// Alvo de toque mínimo recomendado (Material 48dp / Apple HIG 44pt) — o
/// círculo visual (ícone + padding) pode ser menor, mas a área que responde
/// ao toque não deve.
const double _minTouchTarget = 48.0;

class FavoriteButtonWidget extends StatelessWidget {
  final StoreDto store;
  final double iconSize;

  /// Vidro fosco translúcido sobre a foto (efeito do card "Em Alta", igual
  /// ao anexo de referência) em vez do círculo branco opaco padrão.
  final bool frosted;

  const FavoriteButtonWidget({super.key, required this.store, this.iconSize = 18.0, this.frosted = false});

  @override
  Widget build(BuildContext context) {
    // O papel vem do SessionStore, leitura síncrona e sem I/O. Antes era um
    // parâmetro empurrado por até 4 níveis de widget acima daqui, cada nível
    // existindo só para repassá-lo adiante.
    final userRole = SessionStore.instance.role;

    if (userRole == 'GUEST') {
      return _tapArea(
        context,
        label: 'Favoritar ${store.nome}',
        onTap: () => LoginWallHelper.showLoginWallBottomSheet(context),
        icon: Icon(AppIcons.heart, color: frosted ? ColorsPalette.white : context.mapColors.iconMuted, size: iconSize),
      );
    }

    if (userRole == 'COMERCIANTE') {
      return _tapArea(
        context,
        label: 'Favoritar ${store.nome}',
        onTap: () => AppToast.error(context, "Apenas contas de consumidor podem favoritar estabelecimentos."),
        icon: Icon(AppIcons.heart, color: frosted ? ColorsPalette.white : context.mapColors.iconMuted, size: iconSize),
      );
    }

    return ListenableBuilder(
      listenable: FavoritesManager.instance,
      builder: (context, _) {
        final isFavorite = FavoritesManager.instance.isFavorite(store.id);
        return _tapArea(
          context,
          label: isFavorite ? 'Remover ${store.nome} dos favoritos' : 'Favoritar ${store.nome}',
          selected: isFavorite,
          onTap: () async {
            try {
              await FavoritesManager.instance.toggle(store);
              if (!context.mounted) return;
              AppToast.success(context, isFavorite ? "Removido dos favoritos." : "Favoritado com sucesso!");
            } catch (_) {
              if (!context.mounted) return;
              AppToast.error(context, "Não foi possível atualizar seus favoritos. Tente novamente.");
            }
          },
          icon: Icon(
            AppIcons.heart,
            color: isFavorite ? ColorsPalette.redComponents : (frosted ? ColorsPalette.white : context.mapColors.iconMuted),
            size: iconSize,
          ),
        );
      },
    );
  }

  /// [SemanticTapArea] (rótulo + papel de botão pro leitor de tela) como
  /// widget mais externo, com no mínimo 48dp de área de toque — o círculo
  /// visual (`_circle`) fica centralizado dentro dela, sem crescer.
  Widget _tapArea(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required Widget icon,
    bool? selected,
  }) {
    return SemanticTapArea(
      label: label,
      selected: selected,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _minTouchTarget, minHeight: _minTouchTarget),
        child: Center(child: _circle(context, child: icon)),
      ),
    );
  }

  Widget _circle(BuildContext context, {required Widget child}) {
    if (!frosted) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: context.mapColors.cardSurface,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: child,
      );
    }

    // Círculo translúcido sem BackdropFilter de propósito: este botão
    // aparece em listas roláveis (busca, "Em Alta") com vários cards
    // visíveis ao mesmo tempo — cada BackdropFilter força seu próprio
    // saveLayer + blur na GPU, e vários simultâneos durante o scroll eram
    // a maior causa de engasgo do app. Alpha mais alto (0.32 vs 0.28) +
    // sombra compensam visualmente a falta do desfoque de fundo.
    return Container(
      padding: const EdgeInsets.all(9.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.32),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}
