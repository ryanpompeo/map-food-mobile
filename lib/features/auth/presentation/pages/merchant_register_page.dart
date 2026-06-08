import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/widgets/app_form_field_.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/features/merchant/data/models/merchant_register_request.dart';

import 'package:map_food/features/merchant/data/services/merchant_service.dart';

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
        debugPrint("Abrir tela de Termos de Parceiro");
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
    if (!_formKey.currentState!.validate()) return;

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado! Faça login para continuar.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        '/login',
        arguments: 'COMERCIANTE',
      );
    } on AppException catch (e) {
      final msg = e.statusCode == 409
          ? 'E-mail, CPF ou CNPJ já cadastrado.'
          : e.message;
      setState(() => _errorMessage = msg);
    } catch (_) {
      setState(() => _errorMessage = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  icon: LucideIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _emailController,
                  label: "E-mail de Contato",
                  hint: "contato@exemplo.com",
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
                  validator: FormValidator.cpf,
                  inputFormatters: [_cpfFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _cnpjController,
                  label: "CNPJ (Opcional)",
                  hint: "00.000.000/0000-00",
                  icon: LucideIcons.building,
                  keyboardType: TextInputType.number,
                  validator: FormValidator.cnpjOpcional,
                  inputFormatters: [_cnpjFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _celularController,
                  label: "Celular / WhatsApp",
                  hint: "(11) 90000-0000",
                  icon: LucideIcons.smartphone,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefone,
                  inputFormatters: [_celularFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _telefoneController,
                  label: "Telefone Fixo (Opcional)",
                  hint: "(11) 4000-0000",
                  icon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefoneOpcional,
                  inputFormatters: [_telefoneFormatter],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _senhaController,
                  label: "Crie uma Senha",
                  hint: "Mínimo 8 caracteres",
                  icon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  validator: FormValidator.senha,
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
                ),

                const SizedBox(height: AppSpacing.xl),

                FormField<bool>(
                  initialValue: _aceitouTermos,
                  validator: FormValidator.termos,
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
                                  color: state.hasError
                                      ? Colors.red
                                      : Colors.grey.shade400,
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
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                              left: 36.0,
                            ),
                            child: Text(
                              state.errorText!,
                              style: AppText.legenda(
                                context,
                              ).copyWith(color: Colors.red.shade400),
                            ),
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
                        : Text(
                            "Começar a vender",
                            style: AppText.botao(context),
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
