import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/features/auth/data/services/verificacao_email_service.dart';

const int digitosDoCodigo = 6;

const Duration esperaParaReenviar = Duration(seconds: 60);

class VerificarEmailPage extends StatefulWidget {
  final VerificacaoEmailService? servico;

  final bool codigoJaEnviado;

  const VerificarEmailPage({super.key, this.servico, this.codigoJaEnviado = true});

  @override
  State<VerificarEmailPage> createState() => _VerificarEmailPageState();
}

class _VerificarEmailPageState extends State<VerificarEmailPage> {
  late final VerificacaoEmailService _servico = widget.servico ?? VerificacaoEmailService();
  final TextEditingController _codigo = TextEditingController();

  Timer? _contagem;
  int _segundosParaReenviar = 0;
  bool _carregando = true;
  bool _confirmando = false;
  bool _reenviando = false;
  bool _limiteDiario = false;
  String? _emailDaConta;
  String? _erro;

  @override
  void initState() {
    super.initState();
    unawaited(_carregarSituacao());
  }

  Future<void> _carregarSituacao() async {
    final situacao = await _servico.situacao();
    if (!mounted) return;

    if (situacao != null && situacao.jaVerificado) {
      await SessionStore.instance.marcarEmailVerificado(true);
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _carregando = false;
      _limiteDiario = situacao?.limiteDiario ?? false;
      _emailDaConta = situacao?.email.isNotEmpty == true ? situacao!.email : null;
    });

    final segundos =
        situacao?.aguardeSegundos ?? (widget.codigoJaEnviado ? esperaParaReenviar.inSeconds : 0);
    if (segundos > 0) _comecarEspera(segundos);
  }

  @override
  void dispose() {
    _contagem?.cancel();
    _codigo.dispose();
    super.dispose();
  }

  void _comecarEspera(int segundos) {
    _segundosParaReenviar = segundos;
    _contagem?.cancel();
    _contagem = Timer.periodic(const Duration(seconds: 1), (relogio) {
      if (!mounted) return relogio.cancel();
      setState(() => _segundosParaReenviar--);
      if (_segundosParaReenviar <= 0) relogio.cancel();
    });
  }

  Future<void> _confirmar() async {
    final codigo = _codigo.text.trim();
    if (codigo.length != digitosDoCodigo) {
      setState(() => _erro = 'Digite os $digitosDoCodigo números do código');
      return;
    }

    setState(() {
      _confirmando = true;
      _erro = null;
    });
    try {
      await _servico.confirmar(codigo);
      if (!mounted) return;
      AppToast.success(context, 'E-mail confirmado');
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (mounted) setState(() => _erro = e.message);
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não deu para confirmar agora. Tente de novo');
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  Future<void> _reenviar() async {
    setState(() {
      _reenviando = true;
      _erro = null;
    });
    try {
      final aguarde = await _servico.enviarCodigo();
      if (!mounted) return;
      if (SessionStore.instance.emailVerificado) {
        Navigator.of(context).pop(true);
        return;
      }
      AppToast.success(context, 'Código novo enviado');
      _comecarEspera(aguarde ?? esperaParaReenviar.inSeconds);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.message;
        if (e.dados?['limiteDiario'] == true) _limiteDiario = true;
      });
      final aguarde = e.dados?['aguardeSegundos'];
      if (aguarde is num && aguarde > 0) _comecarEspera(aguarde.toInt());
    } catch (_) {
      if (mounted) setState(() => _erro = 'Não deu para enviar o código agora');
    } finally {
      if (mounted) setState(() => _reenviando = false);
    }
  }

  String get _rotuloDoReenvio {
    if (_limiteDiario) return 'Limite de códigos por hoje';
    if (_segundosParaReenviar > 0) return 'Reenviar em ${_segundosParaReenviar}s';
    return 'Reenviar código';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final email = _emailDaConta ?? SessionStore.instance.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirme seu e-mail')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(AppIcons.envelope, size: AppIconSize.xl, color: colors.brandContent),
                    const SizedBox(height: Spacing.md),
                    Text('Digite o código que enviamos', style: AppText.h1(context)),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      email.isEmpty
                          ? 'Enviamos um código de $digitosDoCodigo números para o seu e-mail'
                          : 'Enviamos um código de $digitosDoCodigo números para $email',
                      style: AppText.secondary(context).copyWith(height: 1.4),
                    ),
                    const SizedBox(height: Spacing.lg),
                    AppFormField(
                      controller: _codigo,
                      label: 'Código',
                      hint: '000000',
                      icon: AppIcons.lock,
                      keyboardType: TextInputType.number,
                      maxLength: digitosDoCodigo,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.done,
                      enabled: !_confirmando,
                      onSubmitted: (_) => _confirmar(),
                    ),
                    if (_erro != null) ...[
                      const SizedBox(height: Spacing.sm),
                      FormErrorBanner(message: _erro),
                    ],
                    const SizedBox(height: Spacing.lg),
                    AppButton(
                      label: 'Confirmar',
                      icon: AppIcons.checkCircle,
                      onPressed: _confirmando ? null : _confirmar,
                      loading: _confirmando,
                    ),
                    const SizedBox(height: Spacing.sm),
                    AppButton(
                      label: _rotuloDoReenvio,
                      icon: AppIcons.envelope,
                      variant: AppButtonVariant.outline,
                      onPressed:
                          _limiteDiario || _segundosParaReenviar > 0 || _reenviando || _confirmando
                          ? null
                          : _reenviar,
                      loading: _reenviando,
                    ),
                    const SizedBox(height: Spacing.md),
                    Center(
                      child: TextButton(
                        onPressed: _confirmando ? null : () => Navigator.of(context).pop(false),
                        child: Text(
                          'Confirmar depois',
                          style: AppText.button(context).copyWith(color: colors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Sem confirmar, você pode usar o app normalmente · só não dá para avaliar nem denunciar lojas',
                      style: AppText.caption(
                        context,
                      ).copyWith(color: colors.textSecondary, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
