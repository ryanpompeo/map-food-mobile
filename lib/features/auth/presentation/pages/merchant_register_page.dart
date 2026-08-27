import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
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
import 'package:map_food/features/merchant/data/models/merchant_register_request.dart';
import 'package:map_food/features/merchant/data/services/merchant_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class MerchantRegisterPage extends StatefulWidget {
  const MerchantRegisterPage({super.key});

  @override
  State<MerchantRegisterPage> createState() => _MerchantRegisterPageState();
}

class _MerchantRegisterPageState extends State<MerchantRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _celularController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  // Encadeamento do teclado — o formulário tem sete campos, é onde a falta
  // do "próximo" mais custava: era um toque a mais na tela por campo.
  final _cpfFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _cnpjFocus = FocusNode();
  final _celularFocus = FocusNode();
  final _telefoneFocus = FocusNode();
  final _senhaFocus = FocusNode();

  final _merchantService = MerchantService();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _aceitouTermos = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _celularFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) ####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _celularController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _cpfFocus.dispose();
    _emailFocus.dispose();
    _cnpjFocus.dispose();
    _celularFocus.dispose();
    _telefoneFocus.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_isLoading) return;

    // O aceite entra na validação do Form (ver TermsCheckbox), então o erro
    // aparece embaixo do checkbox em vez de um toast no topo da tela.
    if (!(_formKey.currentState?.validate() ?? false)) {
      FocusScope.of(context).unfocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cnpjDigits = _cnpjFormatter.getUnmaskedText();
      final telefoneDigits = _telefoneFormatter.getUnmaskedText();

      final request = MerchantRegisterRequest(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        cpf: _cpfFormatter.getUnmaskedText(),
        cnpj: cnpjDigits.isEmpty ? null : cnpjDigits,
        celular: _celularFormatter.getUnmaskedText(),
        telefone: telefoneDigits.isEmpty ? null : telefoneDigits,
        senha: _senhaController.text,
      );

      await _merchantService.register(request);

      if (!mounted) return;

      try {
        await _authService.login(
          _emailController.text.trim().toLowerCase(),
          _senhaController.text,
          'COMERCIANTE',
        );
      } on AppException {
        if (!mounted) return;
        unawaited(Navigator.pushReplacementNamed(context, AppRoutes.login,
            arguments: 'COMERCIANTE'));
        return;
      }

      if (!mounted) return;

      // MerchantHomePage detecta que não há loja e redireciona para StoreRegisterPage
      unawaited(Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (_) => const MerchantHomePage()),
        (route) => false,
      ));
    } on AppException catch (e) {
      _mostrarErro(
        e.statusCode == 409 ? 'E-mail, CPF ou CNPJ já cadastrado.' : e.message,
      );
    } catch (e, st) {
      debugPrint('Erro no cadastro de comerciante: $e');
      debugPrint('$st');
      _mostrarErro('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Só o banner inline: o par banner + toast repetia a mesma frase duas
  /// vezes, e a do toast sumia sozinha antes de ser lida.
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
                Text('CONTA DE COMERCIANTE', style: AppText.overline(context)),
                const SizedBox(height: Spacing.sm),
                Text('Crie sua conta', style: AppText.display(context)),
                const SizedBox(height: Spacing.md),
                Text(
                  'Cadastre seu negócio e alcance mais clientes na sua região',
                  style: AppText.body(context).copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: Spacing.xxl),

                _secao(context, 'Dados pessoais'),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _nomeController,
                  label: 'Nome completo',
                  hint: 'João da Silva',
                  icon: AppIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
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
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                ),

                const SizedBox(height: Spacing.xxl),
                _secao(context, 'Dados do negócio'),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'E-mail de contato',
                  hint: 'contato@exemplo.com',
                  icon: AppIcons.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _cnpjFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _cnpjController,
                  focusNode: _cnpjFocus,
                  label: 'CNPJ (opcional)',
                  hint: '00.000.000/0000-00',
                  icon: AppIcons.building,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cnpjFormatter],
                  validator: FormValidator.cnpjOpcional,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _celularFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _celularController,
                  focusNode: _celularFocus,
                  label: 'Celular / WhatsApp',
                  hint: '(11) 90000-0000',
                  icon: AppIcons.deviceMobile,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_celularFormatter],
                  validator: FormValidator.telefone,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _telefoneFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _telefoneController,
                  focusNode: _telefoneFocus,
                  label: 'Telefone fixo (opcional)',
                  hint: '(11) 4000-0000',
                  icon: AppIcons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_telefoneFormatter],
                  validator: FormValidator.telefoneOpcional,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _senhaFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _senhaController,
                  focusNode: _senhaFocus,
                  label: 'Crie uma senha',
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
                  activeColor: MfColor.brand,
                  leadingText: 'Declaro que as informações estão corretas e concordo com os ',
                  primaryLinkLabel: 'Termos de Parceiro',
                  secondaryLinkLabel: null,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Rótulo de grupo do formulário. Em caixa alta e pequeno: separa as duas
  /// metades do cadastro sem competir com o título da tela, que é o único
  /// texto grande daqui.
  Widget _secao(BuildContext context, String titulo) {
    return Text(titulo.toUpperCase(), style: AppText.overline(context));
  }
}
