import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/profile_page_scaffold.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_edit_profile.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/favorites/presentation/pages/consumer_favorites_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/features/reviews/presentation/pages/consumer_complaints_page.dart';
import 'package:map_food/features/reviews/presentation/pages/consumer_review_page.dart';

class ConsumerProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  /// Chamado ao voltar da tela de Editar Perfil, pra quem construiu esta
  /// página poder recarregar nome/e-mail/foto — o card de perfil não
  /// atualiza sozinho porque os dados vêm de fora via [userName]/[userEmail].
  final VoidCallback? onProfileUpdated;

  const ConsumerProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      userName: userName,
      userEmail: userEmail,
      avatarColor: ColorsPalette.blackComponents,
      logoutBackgroundColor: ColorsPalette.black,
      logoutForegroundColor: ColorsPalette.white,
      fetchImagemUrl: () async {
        final session = await AuthStorage.getSession();
        if (session == null) return null;
        final data = await ConsumerService().getById(session.id);
        return data.imagemUrl;
      },
      onDeleteAccount: () async {
        final session = await AuthStorage.getSession();
        if (session == null) return;
        await ConsumerService().delete(session.id);
      },
      onLogoutExtra: () => FavoritesManager.instance.clear(),
      howItWorksPageBuilder: (_) => const HowItWorksPage(),
      minhaContaItems: [
        ProfileMenuItem(
          icon: PhosphorIconsRegular.userGear,
          title: "Editar Perfil",
          subtitle: "Altere seus dados e senha",
          onTap: () async {
            await Navigator.push(
              context,
              appPageRoute(builder: (context) => ConsumerEditProfile()),
            );
            onProfileUpdated?.call();
          },
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.heart,
          title: "Favoritos",
          subtitle: "Lojas que você salvou",
          onTap: () {
            Navigator.push(
              context,
              appPageRoute(builder: (context) => ConsumerFavoritesPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.star,
          title: "Minhas avaliações",
          subtitle: "Lojas que você avaliou",
          onTap: () {
            Navigator.push(
              context,
              appPageRoute(builder: (context) => ConsumerReviewPage()),
            );
          },
        ),
        ProfileMenuItem(
          icon: PhosphorIconsRegular.flag,
          title: "Minhas denuncias",
          subtitle: "Acompanhe a situação de suas denuncias",
          onTap: () {
            Navigator.push(
              context,
              appPageRoute(builder: (context) => const ConsumerComplaintsPage()),
            );
          },
        ),
      ],
    );
  }
}
