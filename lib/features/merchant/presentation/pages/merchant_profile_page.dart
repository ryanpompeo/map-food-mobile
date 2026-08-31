import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/profile_page_scaffold.dart';
import 'package:map_food/core/ui/widgets/stacked_card_carousel.dart';
import 'package:map_food/features/merchant/data/services/merchant_service.dart';
import 'package:map_food/features/contato/presentation/pages/contato_page.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_edit_profile.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_how_it_works.dart';
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
      // "Excluir conta" está temporariamente escondido para o comerciante
      // (sem `onDeleteAccount`, o item some de Configurações): o
      // DELETE /comerciantes/{id} falha com 409 quando a conta tem
      // favoritos na loja, posts, pix ou localização — o backend só limpa
      // denúncias, avaliações e acessos antes de apagar. Reativar assim que
      // o cascade estiver completo em ComercianteController.deletar;
      // MerchantService.delete continua pronto para isso.
      onAvatarTap: () => _abrirEditarPerfil(context),
      howItWorksPageBuilder: (_) => const MerchantHowItWorksPage(),
      // Os cards de estatística ("Dias no App", "Avaliações Recebidas",
      // "Denúncias Recebidas") saíram daqui: o perfil ficou restrito à conta,
      // e desempenho tem tela própria. Com eles foi embora também a cascata de
      // chamadas que os alimentava — uma busca de avaliações **por loja**, em
      // série, mais a de denúncias, todas antes de a tela poder aparecer.
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
          unawaited(abrirDetalheDaLoja(context, store));
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
        ProfileMenuItem(
          icon: AppIcons.envelope,
          title: "Fale conosco",
          subtitle: "Envie dúvidas ou sugestões para a equipe",
          onTap: () => Navigator.push(
            context,
            appPageRoute(builder: (_) => const ContatoPage()),
          ),
        ),
      ],
    );
  }
}
