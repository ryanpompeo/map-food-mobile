import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';

const int minimoDeComentariosParaResumo = 3;

class CardResumoIA extends StatefulWidget {
  final int lojaId;

  final int totalComentarios;

  final bool modoComerciante;

  final bool automatico;

  final AvaliacaoService? servico;

  const CardResumoIA({
    super.key,
    required this.lojaId,
    required this.totalComentarios,
    this.modoComerciante = false,
    this.automatico = false,
    this.servico,
  });

  @override
  State<CardResumoIA> createState() => _CardResumoIAState();
}

class _CardResumoIAState extends State<CardResumoIA> {
  late final AvaliacaoService _servico = widget.servico ?? AvaliacaoService();

  ResumoDeAvaliacoes? _resumo;
  int _comentariosNaGeracao = 0;
  bool _carregando = false;
  String? _erro;

  bool get _temComentariosSuficientes =>
      widget.totalComentarios >= minimoDeComentariosParaResumo;

  @override
  void initState() {
    super.initState();
    if (widget.automatico && _temComentariosSuficientes) _gerar();
  }

  Future<void> _gerar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    final comentariosNoPedido = widget.totalComentarios;
    try {
      final resumo = await _servico.resumirAvaliacoes(
        widget.lojaId,
        modo: widget.modoComerciante ? 'comerciante' : 'publico',
      );
      if (!mounted) return;
      setState(() {
        _resumo = resumo;
        _comentariosNaGeracao = comentariosNoPedido;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Não foi possível gerar agora';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_temComentariosSuficientes) return const SizedBox.shrink();

    final colors = context.mapColors;
    final titulo = widget.modoComerciante ? 'Insights com IA' : 'Resumo com IA';

    return AppCard(
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.sparkle,
                size: escalaIcone(context, AppIconSize.sm),
                color: colors.brandContent,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(titulo, style: AppText.bodyStrong(context)),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildConteudo(context),
        ],
      ),
    );
  }

  Widget _buildConteudo(BuildContext context) {
    final colors = context.mapColors;

    if (_carregando) {
      return Row(
        children: [
          const SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: Spacing.sm),
          Text('Lendo os comentários', style: AppText.secondary(context)),
        ],
      );
    }

    if (_erro != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_erro!, style: AppText.secondary(context)),
          const SizedBox(height: Spacing.sm),
          AppButton(
            label: 'Tentar de novo',
            variant: AppButtonVariant.outline,
            size: AppButtonSize.sm,
            expand: false,
            onPressed: _gerar,
          ),
        ],
      );
    }

    final resumo = _resumo;
    if (resumo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.modoComerciante
                ? 'A IA lê os comentários da sua loja e aponta o que se repete'
                : 'A IA resume o que os clientes falaram desta loja',
            style: AppText.secondary(context),
          ),
          const SizedBox(height: Spacing.sm),
          AppButton(
            label: widget.modoComerciante ? 'Gerar insights' : 'Gerar resumo',
            icon: AppIcons.sparkle,
            size: AppButtonSize.sm,
            expand: false,
            onPressed: _gerar,
          ),
        ],
      );
    }

    if (resumo.totalAvaliacoes < minimoDeComentariosParaResumo) {
      return Text(resumo.resumo, style: AppText.secondary(context));
    }

    final novos = widget.totalComentarios - _comentariosNaGeracao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resumo.resumo,
          style: AppText.corpo(context).copyWith(height: 1.4),
        ),
        for (final alerta in resumo.alertas) ...[
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.warning,
                size: escalaIcone(context, AppIconSize.sm),
                color: MfColor.warning,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(alerta, style: AppText.corpo(context).copyWith(height: 1.4)),
              ),
            ],
          ),
        ],
        if (novos > 0) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            novos == 1
                ? 'Chegou 1 comentário novo depois deste resumo'
                : 'Chegaram $novos comentários novos depois deste resumo',
            style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        Text(
          'Texto gerado por inteligência artificial a partir de '
          '${resumo.totalAvaliacoes} ${resumo.totalAvaliacoes == 1 ? 'comentário' : 'comentários'}',
          style: AppText.legenda(context).copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: Spacing.sm),
        AppButton(
          label: 'Gerar de novo',
          variant: AppButtonVariant.outline,
          size: AppButtonSize.sm,
          expand: false,
          onPressed: _gerar,
        ),
      ],
    );
  }
}
