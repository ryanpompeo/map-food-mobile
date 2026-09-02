import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';

typedef ProfileBasicData = ({
  int id,
  String nome,
  String email,
  String? celular,
  String? imagemUrl,
});

class EditProfilePageScaffold extends StatefulWidget {
  final String sectionTitle;
  final String avatarFallbackLetter;
  final Future<ProfileBasicData> Function() fetchInitial;
  final Future<String?> Function(int id, XFile file) uploadImagem;
  final Future<String?> Function(int id) removerImagem;
  final Widget Function(BuildContext context)? extraFieldBuilder;
  final Future<void> Function({
    required String nome,
    required String email,
    required String celular,
    String? novaSenha,
  }) salvar;

  const EditProfilePageScaffold({
    super.key,
    required this.sectionTitle,
    required this.avatarFallbackLetter,
    required this.fetchInitial,
    required this.uploadImagem,
    required this.removerImagem,
    required this.salvar,
    this.extraFieldBuilder,
  });

  @override
  State<EditProfilePageScaffold> createState() => _EditProfilePageScaffoldState();
}

class _EditProfilePageScaffoldState extends State<EditProfilePageScaffold> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _celularFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  int? _id;
  String? _imagemUrl;
  String _originalNome = '';
  String _originalEmail = '';
  String _originalCelular = '';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingFoto = false;
  bool _showSenha = false;
  bool _showConfirmarSenha = false;
  String? _errorMsg;

  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _carregarDados();
    for (final controller in [_nomeController, _emailController, _celularController, _senhaController, _confirmarSenhaController]) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    final dirty = _computeHasUnsavedChanges();
    if (_hasUnsavedChanges.value != dirty) _hasUnsavedChanges.value = dirty;
  }

  @override
  void dispose() {
    for (final controller in [_nomeController, _emailController, _celularController, _senhaController, _confirmarSenhaController]) {
      controller.removeListener(_onFormChanged);
    }
    _nomeController.dispose();
    _emailController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _hasUnsavedChanges.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    try {
      final data = await widget.fetchInitial();
      if (mounted) {
        _id = data.id;
        _imagemUrl = data.imagemUrl;
        _originalNome = data.nome;
        _originalEmail = data.email;
        _originalCelular = data.celular ?? '';
        _nomeController.text = _originalNome;
        _emailController.text = _originalEmail;
        _celularController.text = _celularFormatter.maskText(_originalCelular);
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível carregar seus dados.');
        Navigator.pop(context);
      }
    }
  }

  Future<void> _trocarFoto() async {
    if (_id == null) return;
    final file = await pickImageFromSheet(context);
    if (file == null) return;

    setState(() => _isUploadingFoto = true);
    try {
      final imagemUrl = await widget.uploadImagem(_id!, file);
      if (!mounted) return;
      setState(() => _imagemUrl = imagemUrl);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível enviar a foto. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isUploadingFoto = false);
    }
  }

  Future<void> _removerFoto() async {
    if (_id == null || _imagemUrl == null) return;
    final confirmou = await confirmarRemocaoFoto(context);
    if (!confirmou || !mounted) return;

    setState(() => _isUploadingFoto = true);
    try {
      final imagemUrl = await widget.removerImagem(_id!);
      if (!mounted) return;
      setState(() => _imagemUrl = imagemUrl);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível remover a foto. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isUploadingFoto = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_id == null) return;

    final novaSenha = _senhaController.text.trim();
    final confirmar = _confirmarSenhaController.text.trim();
    if (novaSenha.isNotEmpty && novaSenha != confirmar) {
      setState(() => _errorMsg = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
    });

    final novoNome = _nomeController.text.trim();
    final novoEmail = _emailController.text.trim();

    try {
      await widget.salvar(
        nome: novoNome,
        email: novoEmail,
        celular: _celularController.text.replaceAll(RegExp(r'\D'), ''),
        novaSenha: novaSenha.isNotEmpty ? novaSenha : null,
      );
      await SessionStore.instance.updateNomeEmail(novoNome, novoEmail);

      if (!mounted) return;
      AppToast.success(context, 'Perfil atualizado com sucesso!');
      Navigator.pop(context);
    } on AppException catch (e) {
      setState(() => _errorMsg = e.message);
    } catch (_) {
      setState(() => _errorMsg = 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool _computeHasUnsavedChanges() =>
      !_isLoading &&
      (_nomeController.text != _originalNome ||
          _emailController.text != _originalEmail ||
          _celularController.text.replaceAll(RegExp(r'\D'), '') != _originalCelular ||
          _senhaController.text.isNotEmpty ||
          _confirmarSenhaController.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
      backgroundColor: context.mapColors.background,
      appBar: AppBar(
        backgroundColor: context.mapColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Editar Perfil',
          style: AppText.h2(context).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.textPrimary),
        ),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(Spacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SemanticTapArea(
                          label: 'Foto do perfil',
                          hint: 'Escolhe uma nova foto',
                          onTap: _isUploadingFoto ? null : _trocarFoto,
                          child: Stack(
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: _isUploadingFoto
                                    ? const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2, color: ColorsPalette.redComponents),
                                      )
                                    : AppNetworkImage(
                                        path: _imagemUrl,
                                        displayWidth: 80.0,
                                        fallback: _buildAvatarInitial(context),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6.0),
                                  decoration: const BoxDecoration(
                                    color: ColorsPalette.redComponents,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2.0)),
                                  ),
                                  child: const Icon(AppIcons.camera, size: 14.0, color: Colors.white),
                                ),
                              ),
                              if (_imagemUrl != null && !_isUploadingFoto)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: SemanticTapArea(
                                    label: 'Remover foto do perfil',
                                    onTap: _removerFoto,
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: context.mapColors.surface,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(BorderSide(color: ColorsPalette.redComponents, width: 1.5)),
                                      ),
                                      child: const Icon(AppIcons.x, size: 12.0, color: ColorsPalette.redComponents),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xl),

                      Text(
                        widget.sectionTitle,
                        style: AppText.h2(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: Spacing.base),

                      AppFormField(
                        label: 'Nome completo',
                        hint: 'Seu nome completo',
                        controller: _nomeController,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: Spacing.base),

                      AppFormField(
                        label: 'E-mail',
                        hint: 'seuemail@exemplo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'E-mail obrigatório';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.base),

                      AppFormField(
                        label: 'Celular',
                        hint: '(XX) 9 XXXX-XXXX',
                        controller: _celularController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_celularFormatter],
                      ),

                      if (widget.extraFieldBuilder != null) ...[
                        const SizedBox(height: Spacing.base),
                        widget.extraFieldBuilder!(context),
                      ],

                      const SizedBox(height: Spacing.xl),

                      Text(
                        'Alterar Senha (opcional)',
                        style: AppText.h2(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: Spacing.base),

                      AppFormField(
                        label: 'Nova senha',
                        hint: 'Mínimo 6 caracteres',
                        controller: _senhaController,
                        obscureText: !_showSenha,
                        suffixIcon: IconButton(
                          icon: Icon(_showSenha ? AppIcons.eyeClosed : AppIcons.eye, size: 20, color: context.mapColors.textTertiary),
                          onPressed: () => setState(() => _showSenha = !_showSenha),
                        ),
                        validator: (v) {
                          if (v != null && v.isNotEmpty && v.length < 6) {
                            return 'Mínimo de 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: Spacing.base),

                      AppFormField(
                        label: 'Confirmar nova senha',
                        hint: 'Repita a senha',
                        controller: _confirmarSenhaController,
                        obscureText: !_showConfirmarSenha,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmarSenha ? AppIcons.eyeClosed : AppIcons.eye,
                            size: 20,
                            color: context.mapColors.textTertiary,
                          ),
                          onPressed: () => setState(() => _showConfirmarSenha = !_showConfirmarSenha),
                        ),
                      ),

                      if (_errorMsg != null) ...[
                        const SizedBox(height: Spacing.base),
                        FormErrorBanner(message: _errorMsg),
                      ],

                      const SizedBox(height: Spacing.xl),

                      AppButton(
                        label: 'Salvar alterações',
                        loading: _isSaving,
                        onPressed: _salvar,
                      ),
                      const SizedBox(height: Spacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildAvatarInitial(BuildContext context) {
    return Center(
      child: Text(
        _nomeController.text.isNotEmpty ? _nomeController.text[0].toUpperCase() : widget.avatarFallbackLetter,
        style: AppText.h1(context).copyWith(fontSize: 32, color: ColorsPalette.redComponents, fontWeight: FontWeight.bold),
      ),
    );
  }
}
