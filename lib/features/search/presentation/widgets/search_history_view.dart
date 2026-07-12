import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/services/search_history_service.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// Lista de "Buscas Recentes", persistidas localmente via
/// [SearchHistoryService]. Widget autocontido: carrega o histórico sozinho
/// ao montar e se recolhe (`SizedBox.shrink`) quando não há nada a mostrar
/// — quem usa só precisa decidir QUANDO montá-lo na árvore (ver instruções
/// de integração).
class SearchHistoryView extends StatefulWidget {
  /// Chamado quando o usuário toca em um termo para refazer a busca.
  /// Quem consome este widget é responsável por atualizar o campo de busca
  /// e disparar a pesquisa — este widget não sabe nada sobre a tela que o
  /// hospeda.
  final ValueChanged<String> onTermSelected;

  const SearchHistoryView({super.key, required this.onTermSelected});

  @override
  State<SearchHistoryView> createState() => _SearchHistoryViewState();
}

class _SearchHistoryViewState extends State<SearchHistoryView> {
  final _service = SearchHistoryService.instance;
  List<String> _terms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final terms = await _service.getHistory();
    if (!mounted) return;
    setState(() {
      _terms = terms;
      _isLoading = false;
    });
  }

  Future<void> _remove(String term) async {
    final updated = await _service.removeTerm(term);
    if (!mounted) return;
    setState(() => _terms = updated);
  }

  Future<void> _clearAll() async {
    await _service.clearHistory();
    if (!mounted) return;
    setState(() => _terms = []);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _terms.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Buscas Recentes',
                style: AppText.subtitulo(context)
                    .copyWith(fontWeight: FontWeight.w800, color: ColorsPalette.black),
              ),
              TextButton(
                onPressed: _clearAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Limpar tudo',
                  style: AppText.legenda(context)
                      .copyWith(color: ColorsPalette.redComponents, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ...List.generate(_terms.length, (index) {
            final term = _terms[index];
            return _HistoryTile(
              term: term,
              onTap: () => widget.onTermSelected(term),
              onRemove: () => _remove(term),
            );
          }),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _HistoryTile({required this.term, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(LucideIcons.clock, size: 18.0, color: Colors.grey.shade400),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                term,
                style: AppText.corpo(context)
                    .copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(LucideIcons.x, size: 16.0, color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
