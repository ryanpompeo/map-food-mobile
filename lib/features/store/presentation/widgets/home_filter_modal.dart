import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';

const List<double?> _raiosKm = [1.0, 5.0, 10.0, 20.0, null];

String _labelRaio(double? km) => km == null ? 'Todos' : '${km.toInt()} km';

const int maxCategoriasFiltro = 3;

class HomeFilterResult {
  final Set<String> categorias;

  final double? raioKm;

  const HomeFilterResult({required this.categorias, required this.raioKm});
}

Future<HomeFilterResult?> showHomeFilterModal(
  BuildContext context, {
  required List<CategoriaModel> categorias,
  required Set<String> categoriasAtivas,
  required double? raioAtivo,
}) {
  return showModalBottomSheet<HomeFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _HomeFilterModalContent(
      categorias: categorias,
      categoriasIniciais: categoriasAtivas,
      raioInicial: raioAtivo,
    ),
  );
}

class _HomeFilterModalContent extends StatefulWidget {
  final List<CategoriaModel> categorias;
  final Set<String> categoriasIniciais;
  final double? raioInicial;

  const _HomeFilterModalContent({
    required this.categorias,
    required this.categoriasIniciais,
    required this.raioInicial,
  });

  @override
  State<_HomeFilterModalContent> createState() => _HomeFilterModalContentState();
}

class _HomeFilterModalContentState extends State<_HomeFilterModalContent> {
  late final Set<String> _categorias = {...widget.categoriasIniciais};

  late double? _raio = widget.raioInicial;

  List<String> get _categoriasOpcoes => ['Todos', ...widget.categorias.map((c) => c.nome)];

  void _alternar(String categoria) {
    if (categoria == 'Todos') {
      setState(_categorias.clear);
      return;
    }
    if (_categorias.contains(categoria)) {
      setState(() => _categorias.remove(categoria));
      return;
    }
    if (_categorias.length >= maxCategoriasFiltro) {
      AppToast.warning(
        context,
        'Você pode combinar até $maxCategoriasFiltro categorias.',
      );
      return;
    }
    setState(() => _categorias.add(categoria));
  }

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
      selectedSurface: corAtiva,
      onSelectedSurface: corTextoSelecionado,
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
            Row(
              children: [
                Expanded(
                  child: Text('Categoria', style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold)),
                ),
                Text(
                  '${_categorias.length}/$maxCategoriasFiltro',
                  style: AppText.legenda(context).copyWith(
                    color: _categorias.length >= maxCategoriasFiltro
                        ? ColorsPalette.redComponents
                        : context.mapColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: _categoriasOpcoes.map((cat) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final isTodos = cat == 'Todos';
                return _buildChip(
                  label: cat,
                  selecionado: isTodos ? _categorias.isEmpty : _categorias.contains(cat),
                  corAtiva: isTodos ? (isDark ? Colors.white : ColorsPalette.black) : corParaCategoria(cat),
                  corTextoSelecionado: isTodos && isDark ? Colors.black : Colors.white,
                  onTap: () => _alternar(cat),
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
                HomeFilterResult(categorias: _categorias, raioKm: _raio),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
