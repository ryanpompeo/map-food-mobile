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

class PageCadastroContaComercial extends StatefulWidget {
  const PageCadastroContaComercial({super.key});

  @override
  State<PageCadastroContaComercial> createState() =>
      _PageCadastroContaComercialState();
}

class _PageCadastroContaComercialState
    extends State<PageCadastroContaComercial> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _celularController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _obscurePassword = true;
  bool _aceitouTermos = false;

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
        print("Abrir tela de Termos de Parceiro");
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

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      final dataCadastro = DateTime.now();
      print("Formulário Vendedor válido!");
      print("Data do Cadastro: $dataCadastro");
      print("CPF: ${_cpfFormatter.getUnmaskedText()}");
      if (_cnpjController.text.isNotEmpty) {
        print("CNPJ: ${_cnpjFormatter.getUnmaskedText()}");
      }
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
                  "Seja um Parceiro",
                  style: AppText.display(context).copyWith(
                    letterSpacing: -1,
                    color: ColorsPalette.vermelhoComponents,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Cadastre seu negócio e aumente suas vendas alcançando mais clientes",
                  style: AppText.secundario(
                    context,
                  ).copyWith(fontSize: 15.sp, height: 1.4),
                ),
                SizedBox(height: 32.h),

     
                AppFormField(
                  controller: _nomeController,
                  label: "Nome Completo ou Razão Social",
                  hint: "João da Silva / João Lanches",
                  icon: LucideIcons.user,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: FormValidator.nome,
                ),
                SizedBox(height: 20.h),

                AppFormField(
                  controller: _emailController,
                  label: "E-mail de Contato",
                  hint: "contato@exemplo.com",
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
                  controller: _cnpjController,
                  label: "CNPJ (Opcional)",
                  hint: "00.000.000/0000-00",
                  icon: LucideIcons.building,
                  keyboardType: TextInputType.number,
                  validator: FormValidator.cnpjOpcional,
                  inputFormatters: [_cnpjFormatter],
                ),
                SizedBox(height: 20.h),

           
                AppFormField(
                  controller: _celularController,
                  label: "Celular / WhatsApp",
                  hint: "(11) 90000-0000",
                  icon: LucideIcons.smartphone,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefone,
                  inputFormatters: [_celularFormatter],
                ),
                SizedBox(height: 20.h),

              
                AppFormField(
                  controller: _telefoneController,
                  label: "Telefone Fixo (Opcional)",
                  hint: "(11) 4000-0000",
                  icon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                  validator: FormValidator.telefoneOpcional,
                  inputFormatters: [_telefoneFormatter],
                ),
                SizedBox(height: 20.h),

  
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
                                activeColor: ColorsPalette.vermelhoComponents,
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
                                    text:
                                        "Declaro que as informações estão corretas e concordo com os ",
                                    style: AppText.secundario(
                                      context,
                                    ).copyWith(height: 1.4),
                                    children: [
                                      TextSpan(
                                        text: "Termos de Parceiro",
                                        recognizer:
                                            _termosParceiroRecognizer, // <-- Adicionado o clique aqui
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
                      backgroundColor: ColorsPalette.vermelhoComponents,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Começar a vender",
                      style: AppText.botao(context),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
