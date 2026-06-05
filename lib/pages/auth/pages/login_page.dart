import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/auth/widgets/app_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _fazerLogin() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bem-vindo\nde volta",
                style: AppText.display(context).copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: ColorsPalette.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Acesse sua conta para continuar no MapFood",
                style: AppText.secundario(
                  context,
                ).copyWith(fontSize: 15.0, height: 1.4),
              ),

              const SizedBox(height: AppSpacing.xl),

              AppFormField(
                controller: _emailController,
                label: "E-mail",
                hint: "seu@email.com",
                icon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => null,
              ),
              const SizedBox(height: AppSpacing.md),

              AppFormField(
                controller: _senhaController,
                label: "Senha",
                hint: "Digite sua senha",
                icon: LucideIcons.lock,
                obscureText: _obscurePassword,
                validator: (v) => null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: Colors.grey.shade500,
                    size: AppIconSize.md,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 8.0),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    debugPrint("Esqueci minha senha");
                  },
                  child: Text(
                    "Esqueceu a senha?",
                    style: AppText.legenda(context).copyWith(
                      color: ColorsPalette.blackDetails,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 52.0,
                child: ElevatedButton(
                  onPressed: _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    foregroundColor: ColorsPalette.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                  ),
                  child: Text("Entrar", style: AppText.botao(context)),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "ou entre com",
                      style: AppText.legenda(
                        context,
                      ).copyWith(color: Colors.grey.shade400),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              OutlinedButton(
                onPressed: () => debugPrint("Google Login"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52.0),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.globe,
                      color: ColorsPalette.blackDetails,
                      size: 20.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      "Continuar com Google",
                      style: AppText.corpo(
                        context,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/accountType'),
                  child: Text.rich(
                    TextSpan(
                      text: "Não tem uma conta? ",
                      style: AppText.secundario(context),
                      children: [
                        TextSpan(
                          text: "Cadastre-se",
                          style: AppText.secundario(context).copyWith(
                            color: ColorsPalette.blackDetails,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
