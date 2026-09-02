import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

typedef HowItWorksStep = ({IconData icone, String titulo, String descricao});

class HowItWorksScaffold extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<HowItWorksStep> passos;
  final String ctaLabel;

  final AppButtonVariant ctaVariant;

  final VoidCallback? onCta;

  const HowItWorksScaffold({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.passos,
    required this.ctaLabel,
    this.ctaVariant = AppButtonVariant.primary,
    this.onCta,
  });

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
                Text(titulo, style: AppText.display(context)),
                const SizedBox(height: Spacing.sm),
                Text(
                  subtitulo,
                  style: AppText.body(context).copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Spacing.xl),
                for (int i = 0; i < passos.length; i++)
                  _PassoNaLinha(
                    numero: i + 1,
                    passo: passos[i],
                    ultimo: i == passos.length - 1,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.md),
            child: SafeArea(
              top: false,
              child: AppButton(
                label: ctaLabel,
                variant: ctaVariant,
                onPressed: onCta ?? () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassoNaLinha extends StatelessWidget {
  final int numero;
  final HowItWorksStep passo;
  final bool ultimo;

  const _PassoNaLinha({
    required this.numero,
    required this.passo,
    required this.ultimo,
  });

  static const double _ladoBolha = 44.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final lado = escalaComTeto(context, _ladoBolha);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: lado,
            child: Column(
              children: [
                Container(
                  width: lado,
                  height: lado,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MfColor.brand.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passo.icone,
                    color: MfColor.brand,
                    size: escalaIcone(context, AppIconSize.lg),
                  ),
                ),
                if (!ultimo)
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: colors.divider),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : Spacing.xl),
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
          ),
        ],
      ),
    );
  }
}
