import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/features/auth/presentation/pages/verificar_email_page.dart';

String motivoParaConfirmarEmail({required bool comerciante}) => comerciante
    ? 'Confirmar garante que o e-mail é seu: é por ele que falamos da sua conta '
      'e das denúncias que sua loja receber'
    : 'Enquanto não confirmar, você não consegue avaliar nem denunciar lojas';

String motivoCurtoParaConfirmarEmail({required bool comerciante}) => comerciante
    ? 'Confirmar não trava nada no app · serve para o e-mail ser mesmo seu'
    : 'Sem confirmar, você pode usar o app normalmente · só não dá para avaliar nem denunciar lojas';

bool ehBloqueioPorEmailNaoVerificado(Object erro) {
  if (erro is! AppException || erro.statusCode != 403) return false;
  final mensagem = erro.message.toLowerCase();
  return mensagem.contains('confirme seu e-mail') ||
      mensagem.contains('confirme seu email') ||
      SessionStore.instance.precisaVerificarEmail;
}

Future<bool> abrirConfirmacaoDeEmail(BuildContext context) async {
  final confirmou = await Navigator.of(context).push<bool>(
    appPageRoute(builder: (_) => const VerificarEmailPage()),
  );
  return confirmou ?? false;
}

Future<bool> pedirParaConfirmarEmail(BuildContext context, String mensagem) async {
  final querConfirmar = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: const Text('Confirme seu e-mail'),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogo).pop(false),
          child: const Text('Agora não'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogo).pop(true),
          child: const Text('Confirmar agora'),
        ),
      ],
    ),
  );

  if (querConfirmar != true || !context.mounted) return false;
  return abrirConfirmacaoDeEmail(context);
}
