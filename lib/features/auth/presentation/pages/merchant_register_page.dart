import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';
import 'package:map_food/features/merchant/data/models/merchant_register_request.dart';
import 'package:map_food/features/merchant/data/services/merchant_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';

class MerchantRegisterPage extends StatefulWidget {
  const MerchantRegisterPage({super.key});

  @override
  State<MerchantRegisterPage> createState() => _MerchantRegisterPageSizeState();
}

class _MerchantRegisterPageSizeState extends State<MerchantRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _celularController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  final _merchantService = MerchantService();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _aceitouTermos = false;
  bool _isLoading = false;
  String? _errorMessage;

  // ==========================================
  // DEFINIÇÃO DAS MÁSCARAS
  // ==========================================
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

  late TapGestureRecognizer _termosParceiroRecognizer;

  @override
  void initState() {
    super.initState();

    _termosParceiroRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          appPageRoute(builder: (_) => TermosPage()),
        );
      };
  }

  @override
  void dispose() {
    _termosParceiroRecognizer.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _cnpjController.dispose();
    _celularController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (_isLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_aceitouTermos) {
      _mostrarErro('Você precisa aceitar os Termos de Uso.');
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
        email: _emailController.text.trim(),
        cpf: _cpfFormatter.getUnmaskedText(),
        cnpj: cnpjDigits.isEmpty ? null : cnpjDigits,
        celular: _celularFormatter.getUnmaskedText(),
        telefone: telefoneDigits.isEmpty ? null : telefoneDigits,
        senha: _senhaController.text,
      );

      await _merchantService.register(request);

      if (!mounted) return;

      // Login automático após cadastro
      try {
        await _authService.login(
          _emailController.text.trim(),
          _senhaController.text,
          'COMERCIANTE',
        );
      } on AppException {
        // Se o login automático falhar, direciona para a tela de login
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: 'COMERCIANTE',
        );
        return;
      }

      if (!mounted) return;

      // MerchantHomePage detecta que não há loja e redireciona para StoreRegisterPage
      Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (_) => const MerchantHomePage()),
        (route) => false,
      );
    } on AppException catch (e) {
      final msg = e.statusCode == 409
          ? 'E-mail, CPF ou CNPJ já cadastrado.'
          : e.message;
      _mostrarErro(msg);
    } catch (e, st) {
      debugPrint('Erro no cadastro de comerciante: $e');
      debugPrint('$st');
      _mostrarErro('Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String msg) {
    if (!mounted) return;
    setState(() => _errorMessage = msg);
    AppToast.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: ColorsPalette.whiteBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Crie sua conta",
                  style: AppText.display(context).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: ColorsPalette.redComponents,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Cadastre seu negócio e aumente suas vendas alcançando mais clientes",
                  style: AppText.secundario(
                    context,
                  ).copyWith(fontSize: 15.0, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppFormField(
                  controller: _nomeController,
                  label: "Nome Completo",
                  hint: "João da Silva",
                  icon: PhosphorIconsRegular.user,
                  keyboardType: TextInputType.name,
                  validator: FormValidator.nome,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _emailController,
                  label: "E-mail de Contato",
                  hint: "contato@exemplo.com",
                  icon: PhosphorIconsRegular.envelope,
                  validator: FormValidator.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _cpfController,
                  label: "CPF",
                  hint: "000.000.000-00",
                  icon: PhosphorIconsRegular.creditCard,
                  keyboardType: TextInputType.number,
                  validator: FormValidator.cpf,
                  inputFormatters: [_cpfFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _cnpjController,
                  label: "CNPJ (Opcional)",
                  hint: "00.000.000/0000-00",
                  icon: PhosphorIconsRegular.building,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cnpjFormatter],
                  validator: FormValidator.cnpjOpcional,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _celularController,
                  label: "Celular / WhatsApp",
                  hint: "(11) 90000-0000",
                  icon: PhosphorIconsRegular.deviceMobile,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefone,
                  inputFormatters: [_celularFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _telefoneController,
                  label: "Telefone Fixo (Opcional)",
                  hint: "(11) 4000-0000",
                  icon: PhosphorIconsRegular.phone,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefoneOpcional,
                  inputFormatters: [_telefoneFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _senhaController,
                  label: "Crie uma Senha",
                  hint: "Mínimo 6 caracteres",
                  icon: PhosphorIconsRegular.lock,
                  validator: FormValidator.senha,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? PhosphorIconsRegular.eyeClosed : PhosphorIconsRegular.eye,
                      color: Colors.grey.shade500,
                      size: AppIconSize.md,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                FormField<bool>(
                  initialValue: _aceitouTermos,
                  builder: (FormFieldState<bool> state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: AppIconSize.lg,
                              width: AppIconSize.lg,
                              child: Checkbox(
                                value: _aceitouTermos,
                                activeColor: ColorsPalette.redComponents,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _aceitouTermos = value ?? false;
                                  });
                                  state.didChange(_aceitouTermos);
                                },
                              ),
                            ),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _aceitouTermos = !_aceitouTermos;
                                  });
                                  state.didChange(_aceitouTermos);
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text:
                                        "Declaro que as informações estão corretas e concordo com os ",
                                    style: AppText.secundario(
                                      context,
                                    ).copyWith(height: 1.4),
                                    children: [
                                      TextSpan(
                                        text: "Termos de Parceiro",
                                        recognizer: _termosParceiroRecognizer,
                                        style: AppText.secundario(context)
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: ColorsPalette.black,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                      const TextSpan(text: "."),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage!,
                    style: AppText.legenda(
                      context,
                    ).copyWith(color: Colors.red.shade600),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.redComponents,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: ColorsPalette.redComponents
                          .withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      elevation: 0,
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            height: AppIconSize.lg,
                            width: AppIconSize.lg,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Criar conta",
                                style: AppText.botao(context),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Icon(
                                PhosphorIconsRegular.caretRight,
                                color: ColorsPalette.white,
                                size: AppIconSize.md,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
