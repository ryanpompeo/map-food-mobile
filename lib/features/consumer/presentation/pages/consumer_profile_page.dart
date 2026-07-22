import 'package:flutter/material.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/profile_page_scaffold.dart';
import 'package:map_food/core/ui/widgets/profile_stat_card.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_edit_profile.dart';
import 'package:map_food/features/favorites/presentation/controllers/favorites_manager.dart';
import 'package:map_food/features/favorites/presentation/pages/consumer_favorites_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/denuncias/presentation/pages/consumer_complaints_page.dart';
import 'package:map_food/features/avaliacoes/presentation/pages/consumer_review_page.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

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

  Future<void> _abrirEditarPerfil(BuildContext context) async {
    await Navigator.push(
      context,
      appPageRoute(builder: (context) => ConsumerEditProfile()),
    );
    onProfileUpdated?.call();
  }

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
      onAvatarTap: () => _abrirEditarPerfil(context),
      howItWorksPageBuilder: (_) => const HowItWorksPage(),
      fetchStats: () async {
        final session = await AuthStorage.getSession();
        final dias = await AuthStorage.diasNoApp();
        final avaliacoes = await AvaliacaoService().getMinhasAvaliacoes();
        final denuncias = session == null
            ? const []
            : await DenunciaService().getMyComplaints(session.id);
        return [
          ProfileStat(label: "Dias no App", value: "$dias"),
          ProfileStat(label: "Lojas Avaliadas", value: "${avaliacoes.length}"),
          ProfileStat(label: "Denúncias Feitas", value: "${denuncias.length}"),
        ];
      },
      featuredSectionTitle: "Meus Favoritos",
      featuredEmptyMessage: "Os comércios que você favoritar aparecerão aqui.",
      featuredRefreshListenable: FavoritesManager.instance,
      fetchFeaturedItems: () async {
        await FavoritesManager.instance.load();
        return FavoritesManager.instance.favorites
            .map((store) => StackedCardItem(
                  id: store.id,
                  title: store.nome,
                  imageUrl: resolveImagemUrl(store.capaUrl),
                ))
            .toList();
      },
      onVerTudoFeatured: () {
        Navigator.push(
          context,
          appPageRoute(builder: (context) => ConsumerFavoritesPage()),
        );
      },
      onFeaturedItemTap: (item) {
        StoreDto? store;
        for (final lojaFavoritada in FavoritesManager.instance.favorites) {
          if (lojaFavoritada.id == item.id) {
            store = lojaFavoritada;
            break;
          }
        }
        if (store == null) {
          AppToast.error(context, "Não foi possível abrir esta loja.");
          return;
        }
        Navigator.push(
          context,
          appPageRoute(builder: (_) => MoreInfoStorePage(store: store!)),
        );
      },
      minhaContaItems: [
        ProfileMenuItem(
          icon: PhosphorIconsRegular.userGear,
          title: "Editar Perfil",
          subtitle: "Altere seus dados e senha",
          onTap: () => _abrirEditarPerfil(context),
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
