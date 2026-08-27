import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/metric_colors.dart';
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
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';

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
      fetchImagemUrl: () async {
        final userId = SessionStore.instance.userId;
        if (userId == null) return null;
        final data = await MerchantService().getById(userId);
        return data.imagemUrl;
      },
      onDeleteAccount: () async {
        final userId = SessionStore.instance.userId;
        if (userId == null) return;
        await MerchantService().delete(userId);
      },
      onAvatarTap: () => _abrirEditarPerfil(context),
      howItWorksPageBuilder: (_) => const MerchantHowItWorksPage(),
      fetchStats: () async {
        final userId = SessionStore.instance.userId;
        if (userId == null) {
          return const [
            ProfileStat(label: "Dias no App", value: "0", color: AppMetricColors.diasNoApp),
            ProfileStat(label: "Avaliações Recebidas", value: "0", color: AppMetricColors.avaliacoes),
            ProfileStat(label: "Denúncias Recebidas", value: "0", color: AppMetricColors.denuncias),
          ];
        }

        final merchant = await MerchantService().getById(userId);
        final dias = merchant.dataCadastro != null
            ? DateTime.now().difference(DateTime.parse(merchant.dataCadastro!)).inDays
            : 0;

        final stores = await StoreService().getByMerchant(userId);
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
          denunciasRecebidas = await DenunciaService().getComplaintsReceivedCount(userId);
        } catch (_) {
          // Endpoint pode não existir ainda no backend em execução.
        }

        return [
          ProfileStat(label: "Dias no App", value: "$dias", color: AppMetricColors.diasNoApp),
          ProfileStat(label: "Avaliações Recebidas", value: "$totalAvaliacoes", color: AppMetricColors.avaliacoes),
          ProfileStat(label: "Denúncias Recebidas", value: "$denunciasRecebidas", color: AppMetricColors.denuncias),
        ];
      },
      featuredSectionTitle: "Minhas Lojas",
      featuredEmptyIcon: AppIcons.storefront,
      featuredEmptyTitle: "Nenhuma loja cadastrada",
      featuredEmptyMessage: "Cadastre sua loja para aparecer no mapa dos clientes.",
      featuredEmptyActionLabel: "Cadastrar loja",
      onFeaturedEmptyAction: () => Navigator.push(
        context,
        appPageRoute(builder: (_) => const StoreRegisterPage()),
      ),
      fetchFeaturedItems: () async {
        final userId = SessionStore.instance.userId;
        if (userId == null) return [];
        final stores = await StoreService().getByMerchant(userId);
        return stores
            .map((store) => StackedCardItem(
                  id: store.id,
                  title: store.nome,
                  imageUrl: resolveImagemUrl(store.capaUrl),
                  subtitle: store.categoriaNomes.isNotEmpty
                      ? store.categoriaNomes.first
                      : (store.categoria.isNotEmpty ? store.categoria : null),
                  rating: store.avaliacao,
                ))
            .toList();
      },
      onFeaturedItemTap: (item) async {
        try {
          final store = await StoreService().getById(item.id as int);
          if (!context.mounted) return;
          unawaited(Navigator.push(
            context,
            appPageRoute(builder: (_) => MoreInfoStorePage(store: store)),
          ));
        } catch (_) {
          if (context.mounted) {
            AppToast.error(context, "Não foi possível abrir esta loja.");
          }
        }
      },
      minhaContaItems: [
        ProfileMenuItem(
          icon: AppIcons.userGear,
          title: "Editar Perfil",
          subtitle: "Altere seus dados e senha",
          onTap: () => _abrirEditarPerfil(context),
        ),
      ],
    );
  }
}
