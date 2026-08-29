import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';

/// Abre o formulário de denúncia de uma loja.
Future<void> showReportStoreDialog(BuildContext context, {required int lojaId}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReportStoreDialog(lojaId: lojaId),
  );
}

class _ReportStoreDialog extends StatefulWidget {
  final int lojaId;

  const _ReportStoreDialog({required this.lojaId});

  @override
  State<_ReportStoreDialog> createState() => _ReportStoreDialogState();
}

class _ReportStoreDialogState extends State<_ReportStoreDialog> {
  static const _motivos = [
    'Conteúdo inapropriado',
    'Fraude ou golpe',
    'Informações falsas',
    'Spam',
    'Outro',
  ];
  static const _motivoPadrao = 'Outro';

  String _motivoSelecionado = _motivoPadrao;
  bool _isSubmitting = false;
  final _descricaoController = TextEditingController();
  final _denunciaService = DenunciaService();

  // Guard de "sair sem salvar": só considera alterado se o usuário fugiu do
  // motivo padrão ou escreveu alguma descrição — evita perguntar confirmação
  // pra quem só abriu o dialog e fechou sem preencher nada. ValueNotifier
  // (não bool simples) pra não reconstruir o dialog inteiro a cada tecla —
  // o rebuild fica isolado no ValueListenableBuilder do UnsavedChangesGuard.
  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier(false);

  bool _computeHasUnsavedChanges() =>
      _motivoSelecionado != _motivoPadrao || _descricaoController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // O formulário sempre abre em branco: o backend (contrato legado) não
    // tem checagem de duplicidade nem endpoint pra pré-carregar denúncia
    // existente.
    _descricaoController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final dirty = _computeHasUnsavedChanges();
    if (_hasUnsavedChanges.value != dirty) _hasUnsavedChanges.value = dirty;
  }

  @override
  void dispose() {
    _descricaoController.removeListener(_onFormChanged);
    _descricaoController.dispose();
    _hasUnsavedChanges.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _isSubmitting = true);
    try {
      // POST /denuncias (contrato legado) não extrai o consumidor do JWT —
      // precisa do id da sessão local no corpo da requisição.
      final consumidorId = SessionStore.instance.userId;
      if (consumidorId == null) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        UIUtils.showErrorDialog(context, 'Sessão expirada. Faça login novamente.');
        return;
      }
      await _denunciaService.create(
        lojaId: widget.lojaId,
        consumidorId: consumidorId,
        motivo: _motivoSelecionado,
        descricao: _descricaoController.text.trim(),
      );
      if (!mounted) return;
      // pop() direto (não maybePop): já foi salvo, então fecha sem passar
      // pela confirmação de "sair sem salvar" do PopScope abaixo.
      Navigator.pop(context);
      AppToast.success(context, 'Denúncia enviada.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      // Não fecha o dialog aqui — um erro de validação (ex: descrição muito
      // longa) fechava o dialog e descartava o texto digitado sem explicar
      // o motivo. Mantém o formulário aberto pro usuário corrigir e reenviar.
      UIUtils.showErrorDialog(context, 'Erro ao enviar denúncia. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(Spacing.lg),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.flag, color: colors.brandContent, size: AppIconSize.md),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text('Denunciar comércio', style: AppText.h2(context)),
                    ),
                    IconButton(
                      icon: Icon(AppIcons.x, size: AppIconSize.md, color: colors.textTertiary),
                      onPressed: () => Navigator.maybePop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      tooltip: 'Fechar',
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.',
                  style: AppText.secondary(context),
                ),
                const SizedBox(height: Spacing.lg),

                Text(
                  'Motivo',
                  style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: Spacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  decoration: BoxDecoration(
                    // Mesma superfície rebaixada do AppFormField logo abaixo:
                    // os dois são campos, e antes o seletor usava `surface`
                    // (a cor do próprio dialog) com uma borda vermelha que o
                    // fazia parecer um campo em estado de erro.
                    color: colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: colors.borderStrong),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _motivoSelecionado,
                      isExpanded: true,
                      dropdownColor: colors.surface,
                      borderRadius: BorderRadius.circular(Radii.md),
                      icon: Icon(AppIcons.caretDown, size: 18, color: colors.textSecondary),
                      style: AppText.body(context).copyWith(fontWeight: FontWeight.w500),
                      items: [
                        for (final motivo in _motivos)
                          DropdownMenuItem<String>(
                            value: motivo,
                            child: Text(
                              motivo,
                              style: AppText.body(context).copyWith(
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                      ],
                      onChanged: (novo) {
                        if (novo == null) return;
                        setState(() => _motivoSelecionado = novo);
                        _onFormChanged();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _descricaoController,
                  label: 'Descrição (opcional)',
                  hint: 'Conte mais detalhes sobre o ocorrido...',
                  maxLines: 3,
                  maxLength: 2000,
                  showIcon: false,
                ),
                const SizedBox(height: Spacing.lg),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancelar',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.sm,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: AppButton(
                        label: 'Enviar',
                        size: AppButtonSize.sm,
                        loading: _isSubmitting,
                        onPressed: _enviar,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
