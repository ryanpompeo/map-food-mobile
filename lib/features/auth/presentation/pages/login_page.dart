import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/ui/widgets/app_form_field_.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _tipoLogin = 'CONSUMIDOR';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && (arg == 'CONSUMIDOR' || arg == 'COMERCIANTE')) {
      _tipoLogin = arg;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      setState(() => _errorMessage = 'Preencha e-mail e senha.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(email, senha, _tipoLogin);

      if (!mounted) return;

      if (response.tipo == 'COMERCIANTE') {
        Navigator.pushReplacementNamed(context, AppRoutes.merchantDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.consumerHome);
      }
    } on UnauthorizedException {
      setState(() => _errorMessage = 'E-mail ou senha incorretos.');
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
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

              // Seletor de tipo de conta
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tipoLogin = 'CONSUMIDOR'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _tipoLogin == 'CONSUMIDOR'
                                ? ColorsPalette.redComponents
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Consumidor',
                            style: AppText.legenda(context).copyWith(
                              color: _tipoLogin == 'CONSUMIDOR'
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tipoLogin = 'COMERCIANTE'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: _tipoLogin == 'COMERCIANTE'
                                ? ColorsPalette.redComponents
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Comerciante',
                            style: AppText.legenda(context).copyWith(
                              color: _tipoLogin == 'COMERCIANTE'
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

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

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: AppText.legenda(
                    context,
                  ).copyWith(color: Colors.red.shade600),
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

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
                  onPressed: _isLoading ? null : _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    foregroundColor: ColorsPalette.white,
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
                      : Text("Entrar", style: AppText.botao(context)),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade200)),

                  Expanded(child: Divider(color: Colors.grey.shade200)),
                ],
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
