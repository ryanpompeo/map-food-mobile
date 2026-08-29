import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/features/auth/data/services/auth_service.dart';
import 'package:map_food/features/auth/presentation/widgets/account_type_switch.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _senhaFocus = FocusNode();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String _tipoLogin = 'CONSUMIDOR';
  bool _tipoInicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tipoInicializado) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && (arg == 'CONSUMIDOR' || arg == 'COMERCIANTE')) {
      _tipoLogin = arg;
      _tipoInicializado = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _senhaFocus.dispose();
    super.dispose();
  }

  // Placeholder da recuperação de senha: a entrada já existe na tela para não
  // deixar quem esqueceu a senha sem nenhuma pista do que fazer, mas o fluxo
  // (código por e-mail + redefinição) ainda não tem backend no app.
  void _avisarRecuperacaoIndisponivel() {
    AppToast.info(
      context,
      'Recuperação de senha em desenvolvimento. Em breve você poderá redefinir por aqui.',
    );
  }

  Future<void> _fazerLogin() async {
    if (_isLoading) return;

    // Validação pelo mesmo FormValidator das telas de cadastro — antes esta
    // tela tinha regra própria (`email.contains('@')`), então "a@b" passava
    // aqui e era recusado no cadastro.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.login(
        _emailController.text.trim().toLowerCase(),
        _senhaController.text,
        _tipoLogin,
      );

      if (!mounted) return;

      final destino = response.tipo == 'COMERCIANTE'
          ? AppRoutes.merchantDashboard
          : AppRoutes.consumerHome;
      // pushNamedAndRemoveUntil (não pushReplacementNamed) para limpar todo o
      // histórico de navegação do Guest — sem isso o botão "voltar" do
      // celular retornava ao perfil Guest depois de logado.
      unawaited(
          Navigator.pushNamedAndRemoveUntil(context, destino, (route) => false));
    } on UnauthorizedException {
      setState(() => _errorMessage = 'E-mail ou senha incorretos.');
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Não foi possível entrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isComerciante = _tipoLogin == 'COMERCIANTE';

    return Scaffold(
      // Sem AuthHeroBand: o gradiente vermelho com bolhas coloridas competia
      // com o formulário e era o elemento mais datado da tela. O que abre a
      // tela agora é a tipografia.
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
            // Revalida a cada tecla só depois da primeira tentativa: avisar
            // "e-mail inválido" enquanto a pessoa ainda está digitando a
            // primeira letra é ruído.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bem-vindo\nde volta', style: AppText.display(context)),
                const SizedBox(height: Spacing.md),
                Text(
                  'Acesse sua conta para continuar no MapFood',
                  style: AppText.body(context).copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: Spacing.xxl),

                AccountTypeSwitch(
                  value: _tipoLogin,
                  onChanged: (tipo) => setState(() => _tipoLogin = tipo),
                ),
                const SizedBox(height: Spacing.xl),

                AppFormField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  icon: AppIcons.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: FormValidator.email,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _senhaFocus.requestFocus(),
                ),
                const SizedBox(height: Spacing.base),

                AppFormField(
                  controller: _senhaController,
                  focusNode: _senhaFocus,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  icon: AppIcons.lock,
                  obscureText: _obscurePassword,
                  // Só "campo obrigatório" aqui: as regras de força valem no
                  // cadastro. Aplicá-las no login barraria quem tem senha
                  // antiga, mais curta que a regra atual.
                  validator: (v) => FormValidator.required(v, 'Senha'),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _fazerLogin(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? AppIcons.eyeClosed : AppIcons.eye,
                      color: colors.textTertiary,
                      size: AppIconSize.md,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                const SizedBox(height: Spacing.xs),
                Align(
                  alignment: Alignment.centerRight,
                  child: SemanticTapArea(
                    label: 'Esqueceu sua senha?',
                    hint: 'Recuperação de senha, ainda em desenvolvimento',
                    onTap: _avisarRecuperacaoIndisponivel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      child: Text(
                        'Esqueceu sua senha?',
                        style: AppText.secondary(context).copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: Spacing.base),
                  FormErrorBanner(message: _errorMessage),
                ],

                const SizedBox(height: Spacing.xl),

                AppButton(
                  label: 'Entrar',
                  loading: _isLoading,
                  onPressed: _fazerLogin,
                  // Consumidor entra pelo CTA neutro; comerciante pelo
                  // vermelho — mesma distinção de papel do seletor acima.
                  variant: isComerciante ? AppButtonVariant.primary : AppButtonVariant.inverse,
                ),
                const SizedBox(height: Spacing.xl),

                Center(
                  child: SemanticTapArea(
                    label: 'Cadastre-se',
                    hint: 'Abre a criação de conta',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.accountType),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      child: Text.rich(
                        TextSpan(
                          text: 'Não tem uma conta? ',
                          style: AppText.secondary(context),
                          children: [
                            TextSpan(
                              text: 'Cadastre-se',
                              style: AppText.secondary(context).copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
