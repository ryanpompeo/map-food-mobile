import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/auth/presentation/widgets/account_type_card.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      // Título fora da AppBar: na jornada de entrada, o título é o conteúdo
      // principal da tela, não um rótulo de barra. Mesma abertura das telas
      // de login e cadastro — a sequência inteira lê como um bloco só.
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AppIcons.caretLeft),
          color: colors.textPrimary,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Como você vai usar\no MapFood?', style: AppText.display(context)),
              const SizedBox(height: Spacing.md),
              Text(
                'Escolha o tipo de conta. Dá para criar a outra depois, com o mesmo e-mail.',
                style: AppText.body(context).copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: Spacing.xxl),

              AccountTypeCard(
                highlighted: true,
                icon: AppIcons.user,
                eyebrow: 'Perfil comum',
                title: 'Cliente',
                description: 'Descubra comércios ambulantes perto de você, em tempo real',
                benefits: const [
                  'Localize comércios próximos no mapa',
                  'Avalie e salve seus favoritos',
                  'Acompanhe quem está em rota agora',
                ],
                ctaLabel: 'Seja um Cliente',
                onTap: () => Navigator.pushNamed(context, AppRoutes.consumerRegister),
              ),
              const SizedBox(height: Spacing.base),

              AccountTypeCard(
                icon: AppIcons.storefront,
                eyebrow: 'Perfil comercial',
                title: 'Comerciante',
                description: 'Coloque seu negócio no mapa e alcance mais clientes',
                benefits: const [
                  'Divulgue sua marca no mapa',
                  'Gerencie as informações da sua loja',
                  'Acompanhe avaliações e visitas',
                ],
                ctaLabel: 'Seja um Comerciante',
                onTap: () => Navigator.pushNamed(context, AppRoutes.merchantRegister),
              ),

              const SizedBox(height: Spacing.xl),

              // Saída para quem já tem conta: antes esta tela era um beco —
              // quem chegava aqui vindo do onboarding só voltava pelo botão
              // do topo, e a única porta para o login era o rodapé da
              // própria tela de login, que ficava um passo atrás.
              Center(
                child: SemanticTapArea(
                  label: 'Entrar',
                  hint: 'Abre a tela de entrar com uma conta existente',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                    child: Text.rich(
                      TextSpan(
                        text: 'Já tem uma conta? ',
                        style: AppText.secondary(context),
                        children: [
                          TextSpan(
                            text: 'Entrar',
                            style: AppText.secondary(context).copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
