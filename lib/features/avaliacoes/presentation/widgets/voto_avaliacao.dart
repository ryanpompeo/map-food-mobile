import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/auth/presentation/widgets/aviso_email_nao_verificado.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';

const String votoLike = 'LIKE';
const String votoDeslike = 'DESLIKE';

class VotoAvaliacao extends StatefulWidget {
  final AvaliacaoModel avaliacao;

  final AvaliacaoService? servico;

  const VotoAvaliacao({super.key, required this.avaliacao, this.servico});

  @override
  State<VotoAvaliacao> createState() => _VotoAvaliacaoState();
}

class _VotoAvaliacaoState extends State<VotoAvaliacao> {
  late final AvaliacaoService _servico = widget.servico ?? AvaliacaoService();

  late VotosDaAvaliacao _votos = VotosDaAvaliacao(
    totalLikes: widget.avaliacao.totalLikes,
    totalDeslikes: widget.avaliacao.totalDeslikes,
    meuVoto: widget.avaliacao.meuVoto,
  );

  bool _enviando = false;

  bool get _souOAutor =>
      SessionStore.instance.isConsumidor &&
      SessionStore.instance.userId != null &&
      SessionStore.instance.userId == widget.avaliacao.consumidor?.id;

  Future<void> _votar(String tipo) async {
    if (SessionStore.instance.isGuest) {
      LoginWallHelper.showLoginWallBottomSheet(
        context,
        icon: AppIcons.thumbsUp,
        title: 'Esta avaliação te ajudou?',
        description: 'Crie uma conta grátis para dizer se um comentário foi útil',
      );
      return;
    }
    if (_enviando) return;

    setState(() => _enviando = true);
    try {
      final novos = await _servico.votar(widget.avaliacao.id, tipo);
      if (!mounted) return;
      setState(() {
        _votos = novos;
        _enviando = false;
      });
    } on AppException catch (erro) {
      if (!mounted) return;
      setState(() => _enviando = false);
      if (ehBloqueioPorEmailNaoVerificado(erro)) {
        final confirmou = await pedirParaConfirmarEmail(context, erro.message);
        if (confirmou && mounted) await _votar(tipo);
        return;
      }
      AppToast.error(context, erro.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      AppToast.error(context, 'Não foi possível registrar seu voto');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_souOAutor) return _buildContagemDoAutor(context);

    return Row(
      children: [
        _BotaoDeVoto(
          icone: _votos.meuVoto == votoLike ? AppIcons.thumbsUpFill : AppIcons.thumbsUp,
          total: _votos.totalLikes,
          marcado: _votos.meuVoto == votoLike,
          rotulo: _votos.meuVoto == votoLike
              ? 'Você marcou esta avaliação como útil, toque para desmarcar'
              : 'Marcar esta avaliação como útil',
          onTap: () => _votar(votoLike),
        ),
        const SizedBox(width: Spacing.sm),
        _BotaoDeVoto(
          icone: _votos.meuVoto == votoDeslike ? AppIcons.thumbsDownFill : AppIcons.thumbsDown,
          total: _votos.totalDeslikes,
          marcado: _votos.meuVoto == votoDeslike,
          rotulo: _votos.meuVoto == votoDeslike
              ? 'Você marcou esta avaliação como não útil, toque para desmarcar'
              : 'Marcar esta avaliação como não útil',
          onTap: () => _votar(votoDeslike),
        ),
      ],
    );
  }

  Widget _buildContagemDoAutor(BuildContext context) {
    if (_votos.totalLikes == 0 && _votos.totalDeslikes == 0) {
      return const SizedBox.shrink();
    }
    final colors = context.mapColors;
    return Row(
      children: [
        Icon(AppIcons.thumbsUp, size: AppIconSize.sm, color: colors.textSecondary),
        const SizedBox(width: 4.0),
        Text('${_votos.totalLikes}', style: AppText.caption(context)),
        const SizedBox(width: Spacing.sm),
        Icon(AppIcons.thumbsDown, size: AppIconSize.sm, color: colors.textSecondary),
        const SizedBox(width: 4.0),
        Text('${_votos.totalDeslikes}', style: AppText.caption(context)),
      ],
    );
  }
}

class _BotaoDeVoto extends StatelessWidget {
  final IconData icone;
  final int total;
  final bool marcado;
  final String rotulo;
  final VoidCallback onTap;

  const _BotaoDeVoto({
    required this.icone,
    required this.total,
    required this.marcado,
    required this.rotulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final cor = marcado ? colors.brandContent : colors.textSecondary;

    return SemanticTapArea(
      label: rotulo,
      selected: marcado,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: AppIconSize.sm, color: cor),
            const SizedBox(width: 4.0),
            Text(
              '$total',
              style: AppText.caption(context).copyWith(
                color: cor,
                fontWeight: marcado ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
