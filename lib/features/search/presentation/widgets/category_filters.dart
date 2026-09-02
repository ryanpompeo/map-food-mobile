import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/utils/category_icons.dart';
import 'package:map_food/core/ui/utils/category_images.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';

class CategoryFiltersWidget extends StatelessWidget {
  final List<String> filtros;

  final String? selecionada;

  final ValueChanged<String?> onFilterChanged;

  const CategoryFiltersWidget({
    super.key,
    required this.filtros,
    required this.selecionada,
    required this.onFilterChanged,
  });

  static const double _tetoEscala = 1.5;

  static const double _ladoCirculo = 72.0;

  static const double _larguraItem = 78.0;

  @override
  Widget build(BuildContext context) {
    return MaxTextScale(
      max: _tetoEscala,
      child: SizedBox(
        height: _ladoCirculo + escalaComTeto(context, 36.0, teto: _tetoEscala),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: filtros.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14.0),
          itemBuilder: (context, index) {
            final nome = filtros[index];
            final isSelected = nome == selecionada;

            return RepaintBoundary(
              child: _CartaoCategoria(
                nome: nome,
                isSelected: isSelected,
                lado: _ladoCirculo,
                largura: _larguraItem,
                onTap: () => onFilterChanged(isSelected ? null : nome),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CartaoCategoria extends StatelessWidget {
  final String nome;
  final bool isSelected;
  final double lado;
  final double largura;
  final VoidCallback onTap;

  const _CartaoCategoria({
    required this.nome,
    required this.isSelected,
    required this.lado,
    required this.largura,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cor = corParaCategoria(nome);
    final arte = imagemParaCategoria(nome);

    return SemanticTapArea(
      label: nome,
      selected: isSelected,
      onTap: onTap,
      child: SizedBox(
        width: largura,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: lado,
              height: lado,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: isSelected ? Border.all(color: cor, width: 1.5) : null,
              ),
              child: _Miolo(nome: nome, arte: arte, cor: cor),
            ),
            const SizedBox(height: 6.0),
            Text(
              nome,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.legenda(context).copyWith(
                fontSize: 11.0,
                height: 1.15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? cor : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Miolo extends StatelessWidget {
  final String nome;

  final String? arte;

  final Color cor;

  const _Miolo({required this.nome, required this.arte, required this.cor});

  static const double _ladoArte = 62.0;

  Widget _icone() => Icon(iconeParaCategoria(nome), size: 31.0, color: cor);

  @override
  Widget build(BuildContext context) {
    final arte = this.arte;
    if (arte == null) return _icone();

    return Image.asset(
      arte,
      width: _ladoArte,
      height: _ladoArte,
      cacheWidth: (_ladoArte * 2).round(),
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _icone(),
    );
  }
}
