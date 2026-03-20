import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/theme/icon_size.dart';
import 'package:map_food/core/theme/radius.dart';
import 'package:map_food/core/theme/spacing.dart';
import 'package:map_food/widgets/app_button.dart';
import 'package:map_food/widgets/form_fields/confirmar_senha_field.dart';
import 'package:map_food/widgets/form_fields/cpf_field.dart';
import 'package:map_food/widgets/form_fields/email_field.dart';
import 'package:map_food/widgets/form_fields/nome_field.dart';
import 'package:map_food/widgets/form_fields/senha_field.dart';
import 'package:map_food/widgets/form_fields/telefone_field.dart';
import 'package:map_food/widgets/google_button.dart';

class PageCadastroContaComercial extends StatefulWidget {
  const PageCadastroContaComercial({super.key});

  @override
  State<PageCadastroContaComercial> createState() =>
      _PageCadastroContaComercialState();
}

class _PageCadastroContaComercialState
    extends State<PageCadastroContaComercial> {
  final _formKey = GlobalKey<FormState>();
  int forcaSenha = 0;
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final cpfController = TextEditingController();
  bool comercio = true;
  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final nome = nomeController.text;
      final email = emailController.text;
      final telefone = telefoneController.text;
      final senha = senhaController.text;
      final confirmarSenha = confirmarSenhaController.text;
      final cpf = cpfController.text;

      debugPrint("Nome: $nome");
      debugPrint("Email: $email");
      debugPrint("Telefone: $telefone");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.brancoBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.brancoBackground,
        elevation: 0,
        foregroundColor: ColorsPalette.brancoBackground,
        surfaceTintColor: ColorsPalette.brancoBackground,
        centerTitle: true,
        title: Text(
          "CRIAR CONTA",
          style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.md.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.lg.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: ColorsPalette.vermelhoComponents.withOpacity(
                              0.20,
                            ),
                          ),
                          color: ColorsPalette.vermelhoComponents.withOpacity(
                            0.12,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Icon(
                          LucideIcons.shoppingBag,
                          color: ColorsPalette.vermelhoComponents,
                          size: AppIconSize.large.sp,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      Text("Conta Comercial", style: AppText.corpo(context)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.lg.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg.w,
                      vertical: AppSpacing.md.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsPalette.branco,
                      borderRadius: BorderRadius.circular(AppRadius.xl.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.lg.h),

                        //* Campos
                        NomeField(controller: nomeController),

                        SizedBox(height: AppSpacing.lg.h),

                        EmailField(controller: emailController),

                        SizedBox(height: AppSpacing.lg.h),

                        TelefoneField(
                          controller: telefoneController,
                          comercio: comercio,
                        ),

                        SizedBox(height: AppSpacing.lg.h),

                        CpfField(controller: cpfController),

                        SizedBox(height: AppSpacing.lg.h),
                        SenhaField(controller: senhaController),
                        SizedBox(height: AppSpacing.lg.h),
                        ConfirmarSenhaField(
                          controller: confirmarSenhaController,
                          senhaController: senhaController,
                        ),
                        SizedBox(height: AppSpacing.xxl.h),
                        AppButton(text: 'Criar conta', onPressed: () {}),
                        SizedBox(height: AppSpacing.xxl.h),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: ColorsPalette.cinzaDetails),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'OU CONTINUE COM',
                                style: AppText.legenda(context),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: ColorsPalette.cinzaDetails),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xl.h),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxl.w,
                          ),
                          child: GoogleButton(
                            onPressed: () {
                              print("Login Google");
                            },
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ja tem uma conta? ',
                              style: AppText.legenda(context),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Entrar',
                                style: AppText.destaque(
                                  context,
                                ).copyWith(fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
