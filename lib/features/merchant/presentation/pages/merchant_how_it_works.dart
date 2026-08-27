import 'package:flutter/material.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';

/// Três passos para o comerciante entender a mecânica do app.
///
/// Os passos são **numerados**: são uma sequência de operação (ativar → rodar
/// → colher retorno), e a versão anterior os apresentava como três cards
/// soltos de mesmo peso, sem indicar que um depende do anterior.
class MerchantHowItWorksPage extends StatelessWidget {
  const MerchantHowItWorksPage({super.key});

  static const _passos = [
    (
      icone: AppIcons.storefront,
      titulo: 'Abra sua loja',
      descricao: 'O botão "Abrir loja" é o que coloca você no mapa. Fechada, '
          'você não aparece para ninguém.',
    ),
    (
      icone: AppIcons.navigationArrow,
      titulo: 'Fique em ronda',
      descricao: 'Com a loja aberta, sua posição acompanha o seu deslocamento '
          'automaticamente — quem está por perto vê você se aproximando.',
    ),
    (
      icone: AppIcons.chatCircle,
      titulo: 'Acompanhe as avaliações',
      descricao: 'As notas e comentários dos clientes ficam no perfil da loja. '
          'Reputação alta é o que traz o próximo cliente.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.xl,
              ),
              children: [
                Text('Como funciona', style: AppText.display(context)),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Três passos para o seu comércio ser encontrado por quem está '
                  'perto agora.',
                  style: AppText.body(context).copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                for (int i = 0; i < _passos.length; i++) ...[
                  if (i > 0) const SizedBox(height: Spacing.md),
                  _CardPasso(numero: i + 1, passo: _passos[i]),
                ],
              ],
            ),
          ),
          // Fora do scroll: a saída da tela não deveria depender de rolar até
          // o fim — antes o botão flutuava sobre a lista com 140px de respiro
          // reservado à mão para não cobrir o último card.
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.md),
            child: SafeArea(
              top: false,
              child: AppButton(
                label: 'Entendi, vamos lá',
                onPressed: () => Navigator.pop(context),
                variant: AppButtonVariant.inverse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardPasso extends StatelessWidget {
  final int numero;
  final ({IconData icone, String titulo, String descricao}) passo;

  const _CardPasso({required this.numero, required this.passo});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mesmo tratamento do quadrado de ícone do AccountTypeCard.
          Container(
            width: escalaComTeto(context, 44),
            height: escalaComTeto(context, 44),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MfColor.brand.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(passo.icone, color: MfColor.brand, size: escalaIcone(context, AppIconSize.lg)),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASSO $numero',
                  style: AppText.overline(context).copyWith(color: MfColor.brand),
                ),
                const SizedBox(height: Spacing.xs),
                Text(passo.titulo, style: AppText.title(context)),
                const SizedBox(height: Spacing.xs),
                Text(
                  passo.descricao,
                  style: AppText.secondary(context).copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
