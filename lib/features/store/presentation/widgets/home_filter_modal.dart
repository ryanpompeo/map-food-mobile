import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';

// km; null representa "Todos" (sem filtro de distância).
const List<double?> _raiosKm = [1.0, 5.0, 10.0, 20.0, null];

String _labelRaio(double? km) => km == null ? 'Todos' : '${km.toInt()} km';

class HomeFilterResult {
  final String categoria;
  final double? raioKm;

  const HomeFilterResult({required this.categoria, required this.raioKm});
}

/// Modal de categoria + distância da aba "Início" (guest/consumidor/comerciante).
/// Trocar um chip aqui não afeta o mapa até o usuário tocar em "Aplicar
/// filtros" — só nesse momento o resultado é devolvido pra quem chamou.
Future<HomeFilterResult?> showHomeFilterModal(
  BuildContext context, {
  required List<CategoriaModel> categorias,
  required String categoriaAtiva,
  required double? raioAtivo,
}) {
  return showModalBottomSheet<HomeFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _HomeFilterModalContent(
      categorias: categorias,
      categoriaInicial: categoriaAtiva,
      raioInicial: raioAtivo,
    ),
  );
}

class _HomeFilterModalContent extends StatefulWidget {
  final List<CategoriaModel> categorias;
  final String categoriaInicial;
  final double? raioInicial;

  const _HomeFilterModalContent({
    required this.categorias,
    required this.categoriaInicial,
    required this.raioInicial,
  });

  @override
  State<_HomeFilterModalContent> createState() => _HomeFilterModalContentState();
}

class _HomeFilterModalContentState extends State<_HomeFilterModalContent> {
  late String _categoria = widget.categoriaInicial;
  late double? _raio = widget.raioInicial;

  List<String> get _categoriasOpcoes => ['Todos', ...widget.categorias.map((c) => c.nome)];

  Widget _buildChip({
    required String label,
    required bool selecionado,
    required VoidCallback onTap,
    required Color corAtiva,
    Color corTextoSelecionado = Colors.white,
  }) {
    return AppChoiceChip(
      label: label,
      selected: selecionado,
      onTap: onTap,
      // A cor de identidade da categoria substitui o `selectedSurface` padrão.
      selectedSurface: corAtiva,
      onSelectedSurface: corTextoSelecionado,
      // Um tom abaixo do `surface` do sheet, mesmo raciocínio das superfícies
      // aninhadas do Lote 4A/2 — senão o chip não-selecionado fica quase
      // invisível contra o próprio fundo do modal.
      unselectedSurface: context.mapColors.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: context.mapColors.cardSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.mapColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            Text('Filtrar', style: AppText.titulo(context).copyWith(fontSize: 20.0)),
            const SizedBox(height: AppSpacing.lg),
            Text('Categoria', style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _categoriasOpcoes.map((cat) {
                // "Todos" não é uma categoria de verdade — mantém o par
                // preto/branco que já inverte corretamente no tema escuro
                // (cardSurface escuro deixaria um preto sólido "sumir").
                // Categorias de verdade usam a própria cor de identidade.
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final isTodos = cat == 'Todos';
                return _buildChip(
                  label: cat,
                  selecionado: _categoria == cat,
                  corAtiva: isTodos ? (isDark ? Colors.white : ColorsPalette.black) : corParaCategoria(cat),
                  corTextoSelecionado: isTodos && isDark ? Colors.black : Colors.white,
                  onTap: () => setState(() => _categoria = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Distância', style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _raiosKm.map((raio) {
                return _buildChip(
                  label: _labelRaio(raio),
                  selecionado: _raio == raio,
                  corAtiva: ColorsPalette.redComponents,
                  onTap: () => setState(() => _raio = raio),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Aplicar filtros',
              onPressed: () => Navigator.pop(
                context,
                HomeFilterResult(categoria: _categoria, raioKm: _raio),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
