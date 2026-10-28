import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/features/auth/presentation/widgets/aviso_email_nao_verificado.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/avaliacoes/presentation/widgets/folha_editar_avaliacao.dart';

Future<bool> editarAvaliacaoComUi(
  BuildContext context,
  AvaliacaoModel avaliacao, {
  AvaliacaoService? servico,
}) async {
  final escolha = await mostrarFolhaEditarAvaliacao(
    context,
    nota: avaliacao.nota,
    comentario: avaliacao.comentario,
  );
  if (escolha == null || !context.mounted) return false;

  return _comTratamentoDeErro(
    context,
    acao: () => (servico ?? AvaliacaoService()).editarAvaliacao(
      id: avaliacao.id,
      nota: escolha.nota,
      comentario: escolha.comentario,
    ),
    sucesso: 'Avaliação atualizada',
    falha: 'Erro ao atualizar avaliação',
    repetir: () => editarAvaliacaoComUi(context, avaliacao, servico: servico),
  );
}

Future<bool> excluirAvaliacaoComUi(
  BuildContext context,
  AvaliacaoModel avaliacao, {
  AvaliacaoService? servico,
}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (dialogo) => AlertDialog(
      title: const Text('Excluir avaliação?'),
      content: const Text(
        'Sua nota e seu comentário saem do comércio. Não dá para desfazer',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogo).pop(false),
          child: const Text('Manter'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogo).pop(true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirmou != true || !context.mounted) return false;

  return _comTratamentoDeErro(
    context,
    acao: () => (servico ?? AvaliacaoService()).excluirAvaliacao(avaliacao.id),
    sucesso: 'Avaliação excluída',
    falha: 'Erro ao excluir avaliação',
    repetir: () => excluirAvaliacaoComUi(context, avaliacao, servico: servico),
  );
}

Future<bool> _comTratamentoDeErro(
  BuildContext context, {
  required Future<void> Function() acao,
  required String sucesso,
  required String falha,
  required Future<bool> Function() repetir,
}) async {
  try {
    await acao();
    if (context.mounted) AppToast.success(context, sucesso);
    return true;
  } on AppException catch (erro) {
    if (!context.mounted) return false;
    if (ehBloqueioPorEmailNaoVerificado(erro)) {
      final confirmou = await pedirParaConfirmarEmail(context, erro.message);
      if (confirmou && context.mounted) return repetir();
      return false;
    }
    UIUtils.showErrorDialog(context, '$falha: ${erro.message}');
    return false;
  } catch (erro) {
    if (context.mounted) UIUtils.showErrorDialog(context, '$falha: $erro');
    return false;
  }
}
