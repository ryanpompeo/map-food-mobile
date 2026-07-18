import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/search/presentation/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

class FavoriteButtonWidget extends StatelessWidget {
  final StoreDto store;
  final String userRole;
  final double iconSize;

  /// Vidro fosco translúcido sobre a foto (efeito do card "Em Alta", igual
  /// ao anexo de referência) em vez do círculo branco opaco padrão.
  final bool frosted;

  const FavoriteButtonWidget({super.key, required this.store, required this.userRole, this.iconSize = 18.0, this.frosted = false});

  @override
  Widget build(BuildContext context) {
    if (userRole == 'GUEST') {
      return _circle(
        child: GestureDetector(
          onTap: () => LoginWallHelper.showLoginWallBottomSheet(context),
          child: Icon(PhosphorIconsRegular.heart, color: frosted ? ColorsPalette.white : Colors.grey.shade400, size: iconSize),
        ),
      );
    }

    if (userRole == 'COMERCIANTE') {
      return _circle(
        child: GestureDetector(
          onTap: () => AppToast.error(context, "Apenas contas de consumidor podem favoritar estabelecimentos."),
          child: Icon(PhosphorIconsRegular.heart, color: frosted ? ColorsPalette.white : Colors.grey.shade400, size: iconSize),
        ),
      );
    }

    return AnimatedBuilder(
      animation: FavoritesManager.instance,
      builder: (context, _) {
        final isFavorite = FavoritesManager.instance.isFavorite(store.id);
        return _circle(
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
              PhosphorIconsRegular.heart,
              color: isFavorite ? ColorsPalette.redComponents : (frosted ? ColorsPalette.white : Colors.grey.shade400),
              size: iconSize,
            ),
          ),
        );
      },
    );
  }

  Widget _circle({required Widget child}) {
    if (!frosted) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: ColorsPalette.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ColorsPalette.black.withValues(alpha: 0.12), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: child,
      );
    }

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(9.0),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.28), shape: BoxShape.circle),
          child: child,
        ),
      ),
    );
  }
}
