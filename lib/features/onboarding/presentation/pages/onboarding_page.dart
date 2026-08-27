import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/storage/onboarding_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

/// Boas-vindas da primeira execução. Só aparece quando **não há sessão
/// salva** e a marca de "já visto" ainda não existe (ver [main]) — quem já
/// está logado continua caindo direto na home do seu papel, e quem já passou
/// por aqui uma vez nunca mais vê esta tela.
///
/// "Continuar sem conta" existe porque o MapFood é navegável sem login: o
/// mapa, a busca e as lojas funcionam como visitante, e o login só é exigido
/// nas ações que precisam de conta (favoritar, avaliar, denunciar). Sem essa
/// saída, o onboarding viraria uma parede de cadastro na frente do app.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  static const _destaques = [
    (icon: AppIcons.mapPin, texto: 'Veja quem está vendendo perto de você'),
    (icon: AppIcons.navigationArrow, texto: 'Acompanhe a rota em tempo real'),
    (icon: AppIcons.star, texto: 'Avalie e salve seus favoritos'),
  ];

  Future<void> _continuarSemConta(BuildContext context) async {
    await OnboardingStorage.marcarVisto();
    if (!context.mounted) return;
    unawaited(Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.root, (route) => false));
  }

  /// Deixa a home de visitante **embaixo** da tela de cadastro em vez de
  /// substituir a pilha por ela: sem isso, o "voltar" de dentro do cadastro
  /// não teria pra onde ir (o onboarding já foi removido) e fecharia o app.
  Future<void> _comecar(BuildContext context) async {
    await OnboardingStorage.marcarVisto();
    if (!context.mounted) return;
    unawaited(Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.root, (route) => false));
    unawaited(Navigator.pushNamed(context, AppRoutes.accountType));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xl, Spacing.lg, Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Quadrado de ícone acima do título: acompanha a escala, mesmo
              // tratamento do AccountTypeCard.
              //
              // A marca de verdade no lugar das iniciais "MF": este é o
              // primeiro contato de quem abre o app, e duas letras num
              // quadrado não são um logo — são o placeholder de um. O mesmo
              // pin vermelho do ícone do aplicativo (assets/icon/app_icon.png,
              // aqui na cópia já declarada em assets/images/) é o que a pessoa
              // acabou de tocar na tela inicial do celular.
              Container(
                height: escalaComTeto(context, 60),
                width: escalaComTeto(context, 60),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  // Superfície de marca (vermelho bem diluído) em vez do bloco
                  // `ink`: o logo é vermelho sólido e precisa de um fundo que
                  // o deixe respirar nos dois temas — `primaryContainer` já é
                  // o par brandSurface/brandSurfaceDark do AppTheme.
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Image.asset(
                    'assets/images/app_icon_copy.png',
                    fit: BoxFit.contain,
                    // Decorativo: o título logo abaixo já nomeia o produto.
                    excludeFromSemantics: true,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xl),

              Text('Comida de rua,\nperto de você', style: AppText.display(context)),
              const SizedBox(height: Spacing.md),
              Text(
                'Encontre comerciantes ambulantes em tempo real e descubra quem está em rota agora.',
                style: AppText.body(context).copyWith(color: colors.textSecondary),
              ),

              const SizedBox(height: Spacing.xxl),

              // Substitui o "Descubra • Avalie • Favorite" que ficava solto no
              // rodapé: diz as mesmas três coisas, mas de forma concreta e
              // ancorada em ícone — e no lugar onde a pessoa está lendo.
              for (final destaque in _destaques) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.base),
                  child: Row(
                    children: [
                      Icon(destaque.icon, size: AppIconSize.md, color: MfColor.brand),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          destaque.texto,
                          style: AppText.body(context).copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 3),

              AppButton(
                label: 'Começar',
                icon: AppIcons.arrowRight,
                onPressed: () => _comecar(context),
              ),
              const SizedBox(height: Spacing.sm),
              AppButton(
                label: 'Continuar sem conta',
                variant: AppButtonVariant.ghost,
                onPressed: () => _continuarSemConta(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
