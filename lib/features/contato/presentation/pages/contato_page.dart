import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/contato/data/services/contato_service.dart';

class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _formKey = GlobalKey<FormState>();

  late final _nomeController = TextEditingController(text: SessionStore.instance.nome);
  late final _emailController = TextEditingController(text: SessionStore.instance.email);
  final _telefoneController = TextEditingController();
  final _assuntoController = TextEditingController();
  final _mensagemController = TextEditingController();

  final _emailFocus = FocusNode();
  final _telefoneFocus = FocusNode();
  final _assuntoFocus = FocusNode();
  final _mensagemFocus = FocusNode();

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _service = ContatoService();

  bool _enviando = false;
  String? _errorMessage;

  final ValueNotifier<bool> _temRascunho = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    for (final c in [_assuntoController, _mensagemController, _telefoneController]) {
      c.addListener(_avaliarRascunho);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nomeController,
      _emailController,
      _telefoneController,
      _assuntoController,
      _mensagemController,
    ]) {
      c.dispose();
    }
    for (final f in [_emailFocus, _telefoneFocus, _assuntoFocus, _mensagemFocus]) {
      f.dispose();
    }
    _temRascunho.dispose();
    super.dispose();
  }

  void _avaliarRascunho() {
    final preenchido = _assuntoController.text.trim().isNotEmpty ||
        _mensagemController.text.trim().isNotEmpty ||
        _telefoneController.text.trim().isNotEmpty;
    if (_temRascunho.value != preenchido) _temRascunho.value = preenchido;
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _enviando = true;
      _errorMessage = null;
    });

    try {
      await _service.enviar(
        nome: _nomeController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        assunto: _assuntoController.text,
        mensagem: _mensagemController.text,
      );
      if (!mounted) return;
      _assuntoController.clear();
      _mensagemController.clear();
      _telefoneController.clear();
      AppToast.success(context, 'Mensagem enviada! Responderemos em breve.');
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _errorMessage = 'Não foi possível enviar sua mensagem. Tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _temRascunho,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
          ),
          title: Text('Fale conosco', style: AppText.h2(context)),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.xxl,
              ),
              children: [
                Text(
                  'Tem dúvidas ou sugestões?',
                  style: AppText.display(context),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Escreva para a equipe do MapFood. Respondemos no e-mail que '
                  'você informar aqui.',
                  style: AppText.body(context).copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Spacing.xl),

                if (_errorMessage != null) ...[
                  FormErrorBanner(message: _errorMessage),
                  const SizedBox(height: Spacing.base),
                ],

                AppFormField(
                  controller: _nomeController,
                  label: 'Nome completo',
                  hint: 'João da Silva',
                  icon: AppIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
                  enabled: !_enviando,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'E-mail',
                  hint: 'joao@exemplo.com',
                  icon: AppIcons.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email,
                  enabled: !_enviando,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _telefoneFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _telefoneController,
                  focusNode: _telefoneFocus,
                  label: 'Telefone (opcional)',
                  hint: '(11) 98765-4321',
                  icon: AppIcons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_telefoneFormatter],
                  validator: FormValidator.telefoneOpcional,
                  enabled: !_enviando,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _assuntoFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _assuntoController,
                  focusNode: _assuntoFocus,
                  label: 'Assunto',
                  hint: 'Sobre o que você quer falar?',
                  icon: AppIcons.note,
                  maxLength: 200,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => FormValidator.required(v, 'Assunto'),
                  enabled: !_enviando,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _mensagemFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _mensagemController,
                  focusNode: _mensagemFocus,
                  label: 'Mensagem',
                  hint: 'Escreva sua mensagem aqui...',
                  icon: AppIcons.chatCircle,
                  maxLines: 6,
                  maxLength: 5000,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => FormValidator.minLength(v, 10, 'Mensagem'),
                  enabled: !_enviando,
                ),
                const SizedBox(height: Spacing.xl),

                AppButton(
                  label: 'Enviar mensagem',
                  icon: AppIcons.envelope,
                  loading: _enviando,
                  onPressed: _enviar,
                ),

                const SizedBox(height: Spacing.xl),
                const _CanalDireto(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CanalDireto extends StatelessWidget {
  const _CanalDireto();

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return AppCard(
      elevation: AppCardElevation.flat,
      child: Row(
        children: [
          Icon(
            AppIcons.envelope,
            size: escalaIcone(context, AppIconSize.md),
            color: colors.textTertiary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ou escreva direto para', style: AppText.caption(context)),
                const SizedBox(height: 2),
                Text(
                  'contato.mapfood@gmail.com',
                  style: AppText.bodyStrong(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
