import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/features/contato/presentation/pages/contato_page.dart';
import 'package:map_food/features/store/presentation/widgets/selo_destaque.dart';

const String precoPlanoDestaque = 'R\$ 29,90';

const List<String> vantagensDoPlanoGratuito = [
  'Cadastro completo da loja',
  'Presença no mapa, com ponto fixo ou em movimento',
  'Foto de capa e galeria',
  'Avaliações dos clientes',
];

const List<String> vantagensDoPlanoDestaque = [
  'Selo de Loja em Destaque nas listas e na sua página',
  'Sua loja sobe nos resultados da busca',
  'Vitrine "Lojas em destaque" na tela inicial',
  'Aparece para quem filtra só lojas em destaque',
];

class PlanoDestaquePage extends StatelessWidget {
  const PlanoDestaquePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      backgroundColor: colors.mainBackground,
      appBar: AppBar(
        backgroundColor: colors.mainBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Plano Destaque',
          style: AppText.subtitulo(context)
              .copyWith(fontWeight: FontWeight.w900, color: colors.primaryText),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              'Apareça primeiro para quem está com fome perto de você',
              style: AppText.h2(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'O MapFood continua gratuito. O Plano Destaque é opcional e muda '
              'onde sua loja aparece para o cliente.',
              style: AppText.secondary(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CartaoDoPlano(
              titulo: 'Plano Gratuito',
              preco: 'Sem custo',
              vantagens: vantagensDoPlanoGratuito,
              destacado: false,
            ),
            const SizedBox(height: AppSpacing.md),
            _CartaoDoPlano(
              titulo: 'Plano Destaque',
              preco: '$precoPlanoDestaque / mês',
              vantagens: vantagensDoPlanoDestaque,
              destacado: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ComoFunciona(),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Falar com a equipe',
              icon: AppIcons.envelope,
              onPressed: () => Navigator.push(
                context,
                appPageRoute(builder: (_) => const ContatoPage()),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _CartaoDoPlano extends StatelessWidget {
  final String titulo;
  final String preco;
  final List<String> vantagens;
  final bool destacado;

  const _CartaoDoPlano({
    required this.titulo,
    required this.preco,
    required this.vantagens,
    required this.destacado,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: AppText.corpo(context).copyWith(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryText,
                  ),
                ),
              ),
              if (destacado) const SeloDestaque(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            preco,
            style: AppText.h2(context).copyWith(
              color: destacado ? MfColor.ratingText : colors.primaryText,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final vantagem in vantagens) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    AppIcons.checkCircle,
                    size: escalaIcone(context, 16.0),
                    color: destacado ? MfColor.rating : colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(vantagem, style: AppText.corpo(context)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComoFunciona extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como funciona a contratação',
            style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'O aplicativo não cobra nem processa pagamento. Você fala com a equipe '
            'do MapFood, combina o pagamento fora do aplicativo, e a equipe ativa o '
            'selo da sua loja. Para cancelar, fale com a equipe do mesmo jeito.',
            style: AppText.corpo(context).copyWith(
              color: colors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
