import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
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

class EsqueciSenhaPage extends StatefulWidget {
  final String emailInicial;

  final String tipoInicial;

  final AuthService? servico;

  const EsqueciSenhaPage({
    super.key,
    this.emailInicial = '',
    this.tipoInicial = 'CONSUMIDOR',
    this.servico,
  });

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  late final AuthService _servico = widget.servico ?? AuthService();
  final _formKey = GlobalKey<FormState>();
  late final _emailController = TextEditingController(
    text: widget.emailInicial,
  );
  late String _tipo = widget.tipoInicial;

  bool _enviando = false;
  String? _erro;
  String? _confirmacao;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final formularioValido = _formKey.currentState?.validate() ?? false;
    if (_confirmacao == null && !formularioValido) return;

    final reenvio = _confirmacao != null;
    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      final mensagem = await _servico.pedirRedefinicaoSenha(
        _emailController.text.trim().toLowerCase(),
        _tipo,
      );
      if (!mounted) return;
      setState(() => _confirmacao = mensagem);
      if (reenvio) AppToast.success(context, 'Enviamos de novo');
    } on AppException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível enviar, tente de novo');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
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
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.lg,
            Spacing.xxl,
          ),
          child: _confirmacao == null
              ? _formulario(context)
              : _enviado(context),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final colors = context.mapColors;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Esqueceu\nsua senha?', style: AppText.display(context)),
          const SizedBox(height: Spacing.md),
          Text(
            'Informe o e-mail da sua conta. Vamos enviar um link para você criar uma senha nova.',
            style: AppText.body(context).copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: Spacing.xxl),
          AccountTypeSwitch(
            value: _tipo,
            onChanged: (tipo) => setState(() => _tipo = tipo),
          ),
          const SizedBox(height: Spacing.xl),
          AppFormField(
            controller: _emailController,
            label: 'E-mail',
            hint: 'seu@email.com',
            icon: AppIcons.envelope,
            keyboardType: TextInputType.emailAddress,
            validator: FormValidator.email,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _enviar(),
          ),
          if (_erro != null) ...[
            const SizedBox(height: Spacing.base),
            FormErrorBanner(message: _erro),
          ],
          const SizedBox(height: Spacing.xl),
          AppButton(
            label: 'Enviar link',
            loading: _enviando,
            onPressed: _enviar,
            variant: _tipo == 'COMERCIANTE'
                ? AppButtonVariant.primary
                : AppButtonVariant.inverse,
          ),
        ],
      ),
    );
  }

  Widget _enviado(BuildContext context) {
    final colors = context.mapColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          AppIcons.envelope,
          size: 48,
          color: ColorsPalette.redComponents,
        ),
        const SizedBox(height: Spacing.lg),
        Text('Confira seu e-mail', style: AppText.display(context)),
        const SizedBox(height: Spacing.md),
        Text(_confirmacao!, style: AppText.body(context)),
        const SizedBox(height: Spacing.base),
        Text(
          'Abra o e-mail ${_emailController.text.trim().toLowerCase()} e toque no link para criar a senha nova. '
          'O link vale por 30 minutos. Se não encontrar, olhe também a caixa de spam.',
          style: AppText.body(context).copyWith(color: colors.textSecondary),
        ),
        if (_erro != null) ...[
          const SizedBox(height: Spacing.base),
          FormErrorBanner(message: _erro),
        ],
        const SizedBox(height: Spacing.xxl),
        AppButton(
          label: 'Voltar para o login',
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.inverse,
        ),
        const SizedBox(height: Spacing.sm),
        AppButton(
          label: 'Enviar de novo',
          loading: _enviando,
          onPressed: _enviar,
          variant: AppButtonVariant.ghost,
        ),
      ],
    );
  }
}
