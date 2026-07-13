import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_home_page.dart';

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

  late TapGestureRecognizer _termosRecognizer;
  late TapGestureRecognizer _privacidadeRecognizer;

  @override
  void initState() {
    super.initState();
    _termosRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TermosPage()),
        );
      };

    _privacidadeRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TermosPage()),
        );
      };
  }

  @override
  void dispose() {
    _termosRecognizer.dispose();
    _privacidadeRecognizer.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
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
        _mostrarErro(
          'Conta criada, mas não foi possível entrar automaticamente. Faça login.',
        );
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: 'CONSUMIDOR',
        );
        return;
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const ConsumerHomePage(),
        ),
        (route) => false,
      );
    } on AppException catch (e) {
      final msg = e.statusCode == 409
          ? 'E-mail ou CPF já cadastrado.'
          : e.message;
      _mostrarErro(msg);
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
            LucideIcons.chevronLeft,
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
                    color: ColorsPalette.blackComponents,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Preencha seus dados para começar a pedir as melhores comidas da região",
                  style: AppText.secundario(
                    context,
                  ).copyWith(fontSize: 15.0, height: 1.4),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppFormField(
                  controller: _nomeController,
                  label: "Nome Completo",
                  hint: "João da Silva",
                  icon: LucideIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _emailController,
                  label: "E-mail",
                  hint: "joao@exemplo.com",
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _cpfController,
                  label: "CPF",
                  hint: "000.000.000-00",
                  icon: LucideIcons.creditCard,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cpfFormatter],
                  validator: FormValidator.cpf,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _telefoneController,
                  label: "Celular",
                  hint: "(11) 90000-0000",
                  icon: LucideIcons.smartphone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_telefoneFormatter],
                  validator: FormValidator.telefone,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _senhaController,
                  label: "Senha",
                  hint: "Mínimo 6 caracteres",
                  icon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.grey.shade500,
                      size: AppIconSize.md,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: FormValidator.senha,
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
                                activeColor: ColorsPalette.black,
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
                                    text: "Eu li e concordo com os ",
                                    style: AppText.secundario(
                                      context,
                                    ).copyWith(height: 1.4),
                                    children: [
                                      TextSpan(
                                        text: "Termos de Uso",
                                        recognizer: _termosRecognizer,
                                        style: AppText.secundario(context)
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                      const TextSpan(text: " e a "),
                                      TextSpan(
                                        text: "Política de Privacidade",
                                        recognizer: _privacidadeRecognizer,
                                        style: AppText.secundario(context)
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
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
                      backgroundColor: ColorsPalette.blackComponents,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black.withValues(
                        alpha: 0.6,
                      ),
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
                                LucideIcons.chevronRight,
                                color: ColorsPalette.white,
                                size: AppIconSize.md,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
