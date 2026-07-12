import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/services/notification_service.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/features/reviews/data/services/denuncia_service.dart';

/// Formulário de denúncia de loja. Descrição do problema é obrigatória —
/// validação **estritamente local** (o botão de enviar fica desabilitado
/// enquanto o campo estiver vazio). Não há `@NotBlank` correspondente no
/// backend: a equipe Web ainda pode não ter esse campo implementado no
/// painel dela, então o backend continua aceitando descrição vazia/nula.
class ReportStoreForm extends StatefulWidget {
  final int lojaId;

  const ReportStoreForm({super.key, required this.lojaId});

  @override
  State<ReportStoreForm> createState() => _ReportStoreFormState();
}

class _ReportStoreFormState extends State<ReportStoreForm> {
  static const _motivos = [
    'Conteúdo inapropriado',
    'Fraude ou golpe',
    'Informações falsas',
    'Spam',
    'Outro',
  ];

  final _denunciaService = DenunciaService();
  final _descricaoController = TextEditingController();

  String _motivoSelecionado = 'Outro';
  bool _isSubmitting = false;
  bool _descricaoValida = false;

  @override
  void initState() {
    super.initState();
    _descricaoController.addListener(() {
      final valida = _descricaoController.text.trim().isNotEmpty;
      if (valida != _descricaoValida) setState(() => _descricaoValida = valida);
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await _denunciaService.create(
        lojaId: widget.lojaId,
        motivo: _motivoSelecionado,
        descricao: _descricaoController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      NotificationService.instance.success('Denúncia enviada.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      if (e.toString().contains('409') || (e is AppException && e.statusCode == 409)) {
        UIUtils.showErrorDialog(
          context,
          'Você já possui uma denúncia registrada para este comércio. Acesse seu perfil para gerenciá-la.',
        );
      } else {
        UIUtils.showErrorDialog(context, 'Erro ao enviar denúncia. Tente novamente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final podeEnviar = _descricaoValida && !_isSubmitting;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.flag, color: ColorsPalette.redComponents, size: 20),
                      const SizedBox(width: 8),
                      Text('Denunciar loja',
                          style: AppText.titulo(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.',
                style: AppText.corpo(context).copyWith(color: Colors.brown.shade800, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Motivo', style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: ColorsPalette.redComponents.withValues(alpha: 0.3), width: 1.2),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _motivoSelecionado,
                    isExpanded: true,
                    dropdownColor: const Color(0xFFFCF9F9),
                    borderRadius: BorderRadius.circular(12.0),
                    icon: const Icon(LucideIcons.chevronDown, size: 18, color: Colors.black87),
                    items: _motivos
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m, style: AppText.corpo(context).copyWith(color: Colors.black87)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _motivoSelecionado = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Text('Descrição do problema',
                      style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(width: 4),
                  Text('*',
                      style: AppText.legenda(context)
                          .copyWith(fontWeight: FontWeight.bold, color: ColorsPalette.redComponents)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _descricaoController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Conte com detalhes o que aconteceu...',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: ColorsPalette.redComponents),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar', style: AppText.botao(context).copyWith(color: Colors.brown.shade800)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: podeEnviar ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.redComponents,
                      disabledBackgroundColor: ColorsPalette.redComponents.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Enviar denúncia', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
