import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Bloco de uma seção do painel: título, apoio opcional e conteúdo.
///
/// A moldura é a mesma do card de atividade do consumidor (`_decoracaoCard` em
/// `consumer_profile_page.dart`): `surface` + `Radii.xl` + borda de 1px, **sem
/// sombra**. Não usa o `AppCard` porque aquele é um container clicável de
/// lista/grade, com elevação — aqui o card é só um agrupador dentro de uma
/// tela que já rola, e uma sombra por bloco empilharia relevo sem hierarquia.
class AnalyticsSectionCard extends StatelessWidget {
  final String titulo;

  /// Uma linha explicando **o que o número mede**. Existe porque métrica sem
  /// definição é lida como outra coisa: "visitantes" vira "visualizações" na
  /// cabeça de quem lê, e o valor parece baixo demais.
  final String? apoio;

  final Widget child;

  const AnalyticsSectionCard({
    super.key,
    required this.titulo,
    this.apoio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
            ),
            if (apoio != null) ...[
              const SizedBox(height: 2.0),
              Text(
                apoio!,
                style: AppText.legenda(context).copyWith(
                  fontSize: 11.0,
                  height: 1.35,
                  color: colors.textTertiary,
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
