import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/profile_page_scaffold.dart';
import 'package:map_food/features/merchant/data/services/merchant_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_edit_profile.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_how_it_works.dart';

class MerchantProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  const MerchantProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      userName: userName,
      userEmail: userEmail,
      avatarColor: ColorsPalette.redComponents,
      logoutBackgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.1),
      logoutForegroundColor: ColorsPalette.redComponents,
      listIconBackgroundColor: Colors.grey.shade50,
      listIconColor: ColorsPalette.blackDetails,
      fetchImagemUrl: () async {
        final session = await AuthStorage.getSession();
        if (session == null) return null;
        final data = await MerchantService().getById(session.id);
        return data.imagemUrl;
      },
      onDeleteAccount: () async {
        final session = await AuthStorage.getSession();
        if (session == null) return;
        await MerchantService().delete(session.id);
      },
      howItWorksPageBuilder: (_) => const MerchantHowItWorksPage(),
      minhaContaItems: [
        ProfileMenuItem(
          icon: LucideIcons.userCog,
          title: "Editar Perfil",
          subtitle: "Altere seus dados e senha",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MerchantEditProfile()),
            );
          },
        ),
      ],
    );
  }
}
