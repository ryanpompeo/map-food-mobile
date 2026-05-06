import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/validators/form_validator.dart';
import 'package:map_food/widgets/app_form_field.dart';

class PageCadastroUsuario extends StatefulWidget {
  const PageCadastroUsuario({super.key});

  @override
  State<PageCadastroUsuario> createState() => _PageCadastroUsuarioState();
}

class _PageCadastroUsuarioState extends State<PageCadastroUsuario> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _obscurePassword = true;
  bool _aceitouTermos = false;

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  // ==========================================
  // RECONHECEDORES DE GESTO (Para os links)
  // ==========================================
  late TapGestureRecognizer _termosRecognizer;
  late TapGestureRecognizer _privacidadeRecognizer;

  @override
  void initState() {
    super.initState();
    _termosRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print("Abrir tela de Termos de Uso");
      };

    _privacidadeRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print("Abrir tela de Política de Privacidade");
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

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      print("Formulário válido!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.brancoBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.brancoBackground,
        foregroundColor: ColorsPalette.brancoBackground,
        surfaceTintColor: ColorsPalette.brancoBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "",
          style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.vermelhoComponents,
            size: AppIconSize.normal.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Crie sua conta",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Preencha seus dados para começar a pedir as melhores comidas da região.",
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32.h),

                AppFormField(
                  controller: _nomeController,
                  label: "Nome Completo",
                  hint: "João da Silva",
                  icon: LucideIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
                ),
                SizedBox(height: 20.h),

                AppFormField(
                  controller: _emailController,
                  label: "E-mail",
                  hint: "joao@exemplo.com",
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email,
                ),
                SizedBox(height: 20.h),

                AppFormField(
                  controller: _cpfController,
                  label: "CPF",
                  hint: "000.000.000-00",
                  icon: LucideIcons.creditCard,
                  keyboardType: TextInputType.number,
                  validator: FormValidator.cpf,
                  inputFormatters: [_cpfFormatter],
                ),
                SizedBox(height: 20.h),

                AppFormField(
                  controller: _telefoneController,
                  label: "Celular",
                  hint: "(11) 90000-0000",
                  icon: LucideIcons.smartphone,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefone,
                  inputFormatters: [_telefoneFormatter],
                ),
                SizedBox(height: 20.h),

                AppFormField(
                  controller: _senhaController,
                  label: "Senha",
                  hint: "Mínimo 8 caracteres",
                  icon: LucideIcons.lock,
                  obscureText: _obscurePassword,
                  validator: FormValidator.senha,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 32.h),

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
                              height: 24.w,
                              width: 24.w,
                              child: Checkbox(
                                value: _aceitouTermos,
                                activeColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
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
                            SizedBox(width: 12.w),
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
                        if (state.hasError)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h, left: 36.w),
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

                SizedBox(height: 48.h),

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text("Criar conta", style: AppText.botao(context)),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
