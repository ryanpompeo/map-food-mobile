import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/features/auth/presentation/widgets/aviso_email_nao_verificado.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';

const String motivoRiscoSanitario = 'Risco sanitário';

Future<void> showReportStoreDialog(
  BuildContext context, {
  required int lojaId,
  DenunciaService? servico,
  Future<XFile?> Function(BuildContext context)? escolherFoto,
  DateTime Function()? agora,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ReportStoreDialog(
      lojaId: lojaId,
      servico: servico,
      escolherFoto: escolherFoto,
      agora: agora,
    ),
  );
}

class _ReportStoreDialog extends StatefulWidget {
  final int lojaId;

  final DenunciaService? servico;

  final Future<XFile?> Function(BuildContext context)? escolherFoto;

  final DateTime Function()? agora;

  const _ReportStoreDialog({
    required this.lojaId,
    this.servico,
    this.escolherFoto,
    this.agora,
  });

  @override
  State<_ReportStoreDialog> createState() => _ReportStoreDialogState();
}

class _ReportStoreDialogState extends State<_ReportStoreDialog> {
  static const _motivos = [
    motivoRiscoSanitario,
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
  final _itemController = TextEditingController();
  late final DenunciaService _denunciaService = widget.servico ?? DenunciaService();
  late final DateTime Function() _agora = widget.agora ?? DateTime.now;

  DateTime? _dataConsumo;
  XFile? _foto;
  String? _fotoEnviada;

  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier(false);

  bool get _ehSanitario => _motivoSelecionado == motivoRiscoSanitario;

  bool _computeHasUnsavedChanges() =>
      _motivoSelecionado != _motivoPadrao ||
      _descricaoController.text.trim().isNotEmpty ||
      _itemController.text.trim().isNotEmpty ||
      _dataConsumo != null ||
      _foto != null;

  @override
  void initState() {
    super.initState();
    _descricaoController.addListener(_onFormChanged);
    _itemController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final dirty = _computeHasUnsavedChanges();
    if (_hasUnsavedChanges.value != dirty) _hasUnsavedChanges.value = dirty;
  }

  @override
  void dispose() {
    _descricaoController.removeListener(_onFormChanged);
    _descricaoController.dispose();
    _itemController.removeListener(_onFormChanged);
    _itemController.dispose();
    _hasUnsavedChanges.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = _agora();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataConsumo ?? hoje,
      firstDate: hoje.subtract(const Duration(days: 365)),
      lastDate: hoje,
      helpText: 'Quando você consumiu?',
    );
    if (escolhida == null) return;
    setState(() => _dataConsumo = escolhida);
    _onFormChanged();
  }

  Future<void> _escolherFoto() async {
    final escolher = widget.escolherFoto ?? pickImageFromSheet;
    final arquivo = await escolher(context);
    if (arquivo == null) return;
    setState(() {
      _foto = arquivo;
      _fotoEnviada = null;
    });
    _onFormChanged();
  }

  String? _faltaAlgumCampoSanitario() {
    if (_dataConsumo == null) return 'Informe a data em que você consumiu';
    if (_itemController.text.trim().isEmpty) return 'Informe qual item você consumiu';
    if (_foto == null && _fotoEnviada == null) {
      return 'Envie uma foto como evidência da denúncia';
    }
    return null;
  }

  Future<void> _enviar() async {
    if (_ehSanitario) {
      final falta = _faltaAlgumCampoSanitario();
      if (falta != null) {
        AppToast.error(context, falta);
        return;
      }
    }

    setState(() => _isSubmitting = true);
    try {
      final consumidorId = SessionStore.instance.userId;
      if (consumidorId == null) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        UIUtils.showErrorDialog(context, 'Sessão expirada, entre de novo');
        return;
      }

      if (_ehSanitario && _fotoEnviada == null) {
        _fotoEnviada = await _denunciaService.enviarFoto(_foto!);
      }

      await _denunciaService.create(
        lojaId: widget.lojaId,
        consumidorId: consumidorId,
        motivo: _motivoSelecionado,
        descricao: _descricaoController.text.trim(),
        dataConsumo: _ehSanitario ? _dataConsumo : null,
        itemConsumido: _ehSanitario ? _itemController.text : null,
        fotoUrl: _ehSanitario ? _fotoEnviada : null,
      );
      if (!mounted) return;
      Navigator.pop(context);
      AppToast.success(context, 'Denúncia enviada');
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (ehBloqueioPorEmailNaoVerificado(e)) {
        await pedirParaConfirmarEmail(context, e.message);
        return;
      }
      UIUtils.showErrorDialog(context, _mensagemDeErro(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      UIUtils.showErrorDialog(context, 'Erro ao enviar denúncia, tente de novo');
    }
  }

  String _mensagemDeErro(AppException erro) {
    final doServidor = erro.message.trim();
    if (doServidor.isEmpty || doServidor.toLowerCase().contains('exception')) {
      return 'Erro ao enviar denúncia, tente de novo';
    }
    return doServidor;
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
                  'Nossa equipe analisa seu relato — obrigado por manter a plataforma segura',
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

                if (_ehSanitario) ...[
                  Text(
                    'Para denúncia de risco sanitário, a plataforma precisa de prova: '
                    'nós não fazemos perícia do alimento.',
                    style: AppText.caption(context),
                  ),
                  const SizedBox(height: Spacing.base),
                  _buildCampoData(context),
                  const SizedBox(height: Spacing.base),
                  AppFormField(
                    controller: _itemController,
                    label: 'Item consumido',
                    hint: 'O que você comeu ou bebeu',
                    maxLength: 200,
                    showIcon: false,
                  ),
                  const SizedBox(height: Spacing.base),
                  _buildCampoFoto(context),
                  const SizedBox(height: Spacing.base),
                ],

                AppFormField(
                  controller: _descricaoController,
                  label: 'Descrição (opcional)',
                  hint: 'Conte mais detalhes sobre o ocorrido',
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

  Widget _buildCampoData(BuildContext context) {
    final colors = context.mapColors;
    final escolhida = _dataConsumo;

    return Semantics(
      button: true,
      label: escolhida == null
          ? 'Escolher a data em que você consumiu'
          : 'Data do consumo: ${comoDataSimples(escolhida)}, toque para trocar',
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: _escolherData,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.base),
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(color: colors.borderStrong),
          ),
          child: Row(
            children: [
              Icon(AppIcons.calendarBlank, size: AppIconSize.sm, color: colors.textSecondary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  escolhida == null
                      ? 'Data do consumo'
                      : '${escolhida.day.toString().padLeft(2, '0')}/'
                          '${escolhida.month.toString().padLeft(2, '0')}/${escolhida.year}',
                  style: AppText.body(context).copyWith(
                    color: escolhida == null ? colors.textTertiary : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampoFoto(BuildContext context) {
    final colors = context.mapColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          label: _foto == null ? 'Adicionar foto' : 'Trocar foto',
          icon: AppIcons.camera,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.sm,
          onPressed: _escolherFoto,
        ),
        if (_foto != null) ...[
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Icon(AppIcons.checkCircle, size: AppIconSize.sm, color: colors.textSecondary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  _foto!.name.isEmpty ? 'Foto anexada' : _foto!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption(context),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
