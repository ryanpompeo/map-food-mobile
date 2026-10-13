import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/features/auth/presentation/pages/verificar_email_page.dart';

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
