import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/search/presentation/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class FavoriteButtonWidget extends StatelessWidget {
  final StoreDto store;
  final String userRole;
  final double iconSize;

  const FavoriteButtonWidget({super.key, required this.store, required this.userRole, this.iconSize = 18.0});

  @override
  Widget build(BuildContext context) {
    if (userRole == 'GUEST') {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: GestureDetector(
          onTap: () => LoginWallHelper.showLoginWallBottomSheet(context),
          child: Icon(LucideIcons.heart, color: ColorsPalette.white, size: iconSize),
        ),
      );
    }

    return AnimatedBuilder(
      animation: FavoritesManager.instance,
      builder: (context, _) {
        final isFavorite = FavoritesManager.instance.isFavorite(store.id);
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
          child: GestureDetector(
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
            child: Icon(
              LucideIcons.heart,
              color: isFavorite ? ColorsPalette.redComponents : ColorsPalette.white,
              size: iconSize,
            ),
          ),
        );
      },
    );
  }
}
