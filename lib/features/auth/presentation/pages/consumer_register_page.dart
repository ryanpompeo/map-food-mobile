import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';
import 'package:map_food/features/auth/presentation/widgets/terms_checkbox.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_home_page.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ConsumerRegisterPage extends StatefulWidget {
  const ConsumerRegisterPage({super.key});

  @override
  State<ConsumerRegisterPage> createState() => _ConsumerRegisterPageState();
}

class _ConsumerRegisterPageState extends State<ConsumerRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  final _emailFocus = FocusNode();
  final _cpfFocus = FocusNode();
  final _telefoneFocus = FocusNode();
  final _senhaFocus = FocusNode();

  final _consumerService = ConsumerService();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _aceitouTermos = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _emailFocus.dispose();
    _cpfFocus.dispose();
    _telefoneFocus.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_isLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      FocusScope.of(context).unfocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final senha = _senhaController.text;

    try {
      final request = ConsumerRegisterRequest(
        nome: _nomeController.text.trim(),
        email: email,
        cpf: _cpfController.text.replaceAll(RegExp(r'\D'), ''),
        celular: _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
        senha: senha,
      );

      await _consumerService.register(request);

      try {
        await _authService.login(email, senha, 'CONSUMIDOR');
      } on AppException {
        if (!mounted) return;
        setState(() => _errorMessage =
            'Conta criada, mas não foi possível entrar automaticamente. Faça login.');
        unawaited(Navigator.pushReplacementNamed(context, AppRoutes.login,
            arguments: 'CONSUMIDOR'));
        return;
      }

      if (!mounted) return;

      unawaited(Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (_) => const ConsumerHomePage()),
        (route) => false,
      ));
    } on AppException catch (e) {
      _mostrarErro(e.statusCode == 409 ? 'E-mail ou CPF já cadastrado.' : e.message);
    } catch (e, st) {
      debugPrint('Erro no cadastro de consumidor: $e');
      debugPrint('$st');
      _mostrarErro('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String msg) {
    if (!mounted) return;
    setState(() => _errorMessage = msg);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AppIcons.caretLeft),
          color: colors.textPrimary,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xxl),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONTA DE CLIENTE', style: AppText.overline(context)),
                const SizedBox(height: Spacing.sm),
                Text('Crie sua conta', style: AppText.display(context)),
                const SizedBox(height: Spacing.md),
                Text(
                  'Preencha seus dados para descobrir os melhores comércios da sua região',
                  style: AppText.body(context).copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: Spacing.xxl),

                AppFormField(
                  controller: _nomeController,
                  label: 'Nome completo',
                  hint: 'João da Silva',
                  icon: AppIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
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
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _cpfFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _cpfController,
                  focusNode: _cpfFocus,
                  label: 'CPF',
                  hint: '000.000.000-00',
                  icon: AppIcons.identificationCard,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfFormatter],
                  validator: FormValidator.cpf,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _telefoneFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _telefoneController,
                  focusNode: _telefoneFocus,
                  label: 'Celular',
                  hint: '(11) 90000-0000',
                  icon: AppIcons.deviceMobile,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_telefoneFormatter],
                  validator: FormValidator.telefone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _senhaFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _senhaController,
                  focusNode: _senhaFocus,
                  label: 'Senha',
                  hint: 'Mínimo 6 caracteres',
                  icon: AppIcons.lock,
                  obscureText: _obscurePassword,
                  validator: FormValidator.senha,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _cadastrar(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? AppIcons.eyeClosed : AppIcons.eye,
                      color: colors.textTertiary,
                      size: AppIconSize.md,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                const SizedBox(height: Spacing.xl),

                TermsCheckbox(
                  value: _aceitouTermos,
                  onChanged: (value) => setState(() => _aceitouTermos = value),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: Spacing.lg),
                  FormErrorBanner(message: _errorMessage),
                ],

                const SizedBox(height: Spacing.xl),

                AppButton(
                  label: 'Criar conta',
                  loading: _isLoading,
                  onPressed: _cadastrar,
                  variant: AppButtonVariant.inverse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
