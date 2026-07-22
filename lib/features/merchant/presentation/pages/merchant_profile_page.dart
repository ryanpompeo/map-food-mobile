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
import 'package:map_food/features/merchant/data/services/merchant_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_edit_profile.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_how_it_works.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/pages/more_info_store.dart';

class MerchantProfilePage extends StatelessWidget {
  final String userName;
  final String userEmail;

  /// Chamado ao voltar da tela de Editar Perfil, pra quem construiu esta
  /// página poder recarregar nome/e-mail/foto — o card de perfil não
  /// atualiza sozinho porque os dados vêm de fora via [userName]/[userEmail].
  final VoidCallback? onProfileUpdated;

  const MerchantProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.onProfileUpdated,
  });

  Future<void> _abrirEditarPerfil(BuildContext context) async {
    await Navigator.push(
      context,
      appPageRoute(builder: (context) => const MerchantEditProfile()),
    );
    onProfileUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      userName: userName,
      userEmail: userEmail,
      avatarColor: ColorsPalette.redComponents,
      logoutBackgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.1),
      logoutForegroundColor: ColorsPalette.redComponents,
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
      onAvatarTap: () => _abrirEditarPerfil(context),
      howItWorksPageBuilder: (_) => const MerchantHowItWorksPage(),
      fetchStats: () async {
        final session = await AuthStorage.getSession();
        if (session == null) {
          return const [
            ProfileStat(label: "Dias no App", value: "0"),
            ProfileStat(label: "Avaliações Recebidas", value: "0"),
            ProfileStat(label: "Denúncias Recebidas", value: "0"),
          ];
        }

        final merchant = await MerchantService().getById(session.id);
        final dias = merchant.dataCadastro != null
            ? DateTime.now().difference(DateTime.parse(merchant.dataCadastro!)).inDays
            : 0;

        final stores = await StoreService().getByMerchant(session.id);
        int totalAvaliacoes = 0;
        for (final store in stores) {
          try {
            final avaliacoes = await AvaliacaoService().buscarAvaliacoesDaLoja(store.id);
            totalAvaliacoes += avaliacoes.length;
          } catch (_) {
            // Ignora falha pontual de uma loja — não deve zerar as demais.
          }
        }

        // Depende do endpoint GET /denuncias/loja/comerciante/{id}, aditivo
        // ainda não publicado nesta branch da API — cai pra "0" até lá em
        // vez de quebrar a tela.
        int denunciasRecebidas = 0;
        try {
          denunciasRecebidas = await DenunciaService().getComplaintsReceivedCount(session.id);
        } catch (_) {
          // Endpoint pode não existir ainda no backend em execução.
        }

        return [
          ProfileStat(label: "Dias no App", value: "$dias"),
          ProfileStat(label: "Avaliações Recebidas", value: "$totalAvaliacoes"),
          ProfileStat(label: "Denúncias Recebidas", value: "$denunciasRecebidas"),
        ];
      },
      featuredSectionTitle: "Minhas Lojas",
      featuredEmptyMessage: "As lojas que você cadastrar aparecerão aqui.",
      fetchFeaturedItems: () async {
        final session = await AuthStorage.getSession();
        if (session == null) return [];
        final stores = await StoreService().getByMerchant(session.id);
        return stores
            .map((store) => StackedCardItem(
                  id: store.id,
                  title: store.nome,
                  imageUrl: resolveImagemUrl(store.capaUrl),
                ))
            .toList();
      },
      onFeaturedItemTap: (item) async {
        try {
          final store = await StoreService().getById(item.id as int);
          if (!context.mounted) return;
          Navigator.push(
            context,
            appPageRoute(builder: (_) => MoreInfoStorePage(store: store)),
          );
        } catch (_) {
          if (context.mounted) {
            AppToast.error(context, "Não foi possível abrir esta loja.");
          }
        }
      },
      minhaContaItems: [
        ProfileMenuItem(
          icon: PhosphorIconsRegular.userGear,
          title: "Editar Perfil",
          subtitle: "Altere seus dados e senha",
          onTap: () => _abrirEditarPerfil(context),
        ),
      ],
    );
  }
}
