import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/seletor_de_estrelas.dart';

class AvaliacaoEditada {
  final int nota;
  final String? comentario;

  const AvaliacaoEditada({required this.nota, this.comentario});
}

Future<AvaliacaoEditada?> mostrarFolhaEditarAvaliacao(
  BuildContext context, {
  required int nota,
  String? comentario,
}) {
  return showModalBottomSheet<AvaliacaoEditada>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => FolhaEditarAvaliacao(nota: nota, comentario: comentario),
  );
}

class FolhaEditarAvaliacao extends StatefulWidget {
  final int nota;
  final String? comentario;

  const FolhaEditarAvaliacao({super.key, required this.nota, this.comentario});

  @override
  State<FolhaEditarAvaliacao> createState() => _FolhaEditarAvaliacaoState();
}

class _FolhaEditarAvaliacaoState extends State<FolhaEditarAvaliacao> {
  late int _nota = widget.nota;
  late final TextEditingController _comentario =
      TextEditingController(text: widget.comentario ?? '');

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _salvar() {
    Navigator.pop(
      context,
      AvaliacaoEditada(nota: _nota, comentario: _comentario.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Spacing.lg,
          right: Spacing.lg,
          top: Spacing.lg,
          bottom: Spacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Editar sua avaliação', style: AppText.h2(context)),
            const SizedBox(height: 2.0),
            Text(
              'A nota e o comentário novos substituem os que você enviou',
              style: AppText.secondary(context),
            ),
            const SizedBox(height: Spacing.base),
            SeletorDeEstrelas(
              rating: _nota,
              onChanged: (nova) => setState(() => _nota = nova),
            ),
            const SizedBox(height: Spacing.base),
            AppFormField(
              controller: _comentario,
              label: 'Comentário (opcional)',
              hint: 'Conte como foi sua experiência',
              maxLines: 3,
              maxLength: 1000,
              showIcon: false,
            ),
            const SizedBox(height: Spacing.base),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancelar',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Salvar',
                    onPressed: _nota == 0 ? null : _salvar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
