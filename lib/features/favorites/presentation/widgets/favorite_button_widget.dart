import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

const double _minTouchTarget = 48.0;

class FavoriteButtonWidget extends StatelessWidget {
  final StoreDto store;
  final double iconSize;

  final bool frosted;

  const FavoriteButtonWidget({super.key, required this.store, this.iconSize = 18.0, this.frosted = false});

  @override
  Widget build(BuildContext context) {
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
          icon: _heartIcon(
            context,
            isFavorite: isFavorite,
            color: isFavorite ? ColorsPalette.redComponents : (frosted ? ColorsPalette.white : context.mapColors.iconMuted),
          ),
        );
      },
    );
  }

  Widget _heartIcon(BuildContext context, {required bool isFavorite, required Color color}) {
    return AnimatedSwitcher(
      duration: Motion.fast,
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Icon(
        isFavorite ? AppIcons.heartFill : AppIcons.heart,
        key: ValueKey(isFavorite),
        color: color,
        size: iconSize,
      ),
    );
  }

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
