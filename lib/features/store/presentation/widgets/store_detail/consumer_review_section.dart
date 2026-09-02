import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/utils/ui_utils.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_card.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/login_wall_bottom_sheet.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/review_card.dart';
import 'package:map_food/features/store/presentation/widgets/store_detail/section_header.dart';

class ConsumerReviewSection extends StatefulWidget {
  final int lojaId;

  final String userRole;

  final VoidCallback onReviewSubmitted;
  final ValueChanged<bool>? onUnsavedChanged;

  const ConsumerReviewSection({
    super.key,
    required this.lojaId,
    required this.userRole,
    required this.onReviewSubmitted,
    this.onUnsavedChanged,
  });

  @override
  State<ConsumerReviewSection> createState() => _ConsumerReviewSectionState();
}

class _ConsumerReviewSectionState extends State<ConsumerReviewSection> {
  final AvaliacaoService _avaliacaoService = AvaliacaoService();

  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  List<AvaliacaoModel> _minhasAvaliacoes = [];
  bool _isLoadingHistorico = true;
  bool _historicoExpandido = true;

  bool get _isGuest => widget.userRole == 'GUEST';

  bool get _hasUnsavedChanges => _rating > 0 || _commentController.text.trim().isNotEmpty;

  void _notifyUnsavedChanged() => widget.onUnsavedChanged?.call(_hasUnsavedChanges);

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_notifyUnsavedChanged);
    if (_isGuest) {
      _isLoadingHistorico = false;
    } else {
      _carregarHistorico();
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_notifyUnsavedChanged);
    _commentController.dispose();
    widget.onUnsavedChanged?.call(false);
    super.dispose();
  }

  void _mostrarParedeLogin() {
    LoginWallHelper.showLoginWallBottomSheet(
      context,
      icon: AppIcons.star,
      title: 'Conte como foi sua experiência',
      description:
          'Crie uma conta gratuita em segundos para avaliar este comércio e ajudar outras pessoas a decidir.',
    );
  }

  Future<void> _carregarHistorico() async {
    try {
      final todasMinhas = await _avaliacaoService.getMinhasAvaliacoes();
      if (!mounted) return;
      setState(() {
        _minhasAvaliacoes = todasMinhas.where((a) => a.lojaId == widget.lojaId).toList();
        _isLoadingHistorico = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingHistorico = false);
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppToast.error(context, 'Selecione uma nota de 1 a 5 estrelas.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _avaliacaoService.enviarAvaliacao(
        lojaId: widget.lojaId,
        nota: _rating,
        comentario: _commentController.text,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _rating = 0;
        _commentController.clear();
      });
      widget.onUnsavedChanged?.call(false);
      AppToast.success(context, 'Avaliação enviada com sucesso!');
      widget.onReviewSubmitted();
      unawaited(_carregarHistorico());
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      UIUtils.showErrorDialog(
        context,
        'Erro ao enviar avaliação (${e.statusCode ?? 's/ status'}): ${e.message}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      UIUtils.showErrorDialog(context, 'Erro inesperado ao enviar avaliação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLoadingHistorico && !_isGuest) ...[
          const _HistoricoCarregando(),
          const SizedBox(height: Spacing.base),
        ] else if (_minhasAvaliacoes.isNotEmpty) ...[
          _buildHistorico(context),
          const SizedBox(height: Spacing.base),
        ],
        _buildFormulario(context),
      ],
    );
  }

  Widget _buildHistorico(BuildContext context) {
    final total = _minhasAvaliacoes.length;

    return AppCard(
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Suas avaliações',
            subtitle: '$total ${total == 1 ? 'enviada' : 'enviadas'} para este comércio',
            expanded: _historicoExpandido,
            onToggle: () => setState(() => _historicoExpandido = !_historicoExpandido),
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: !_historicoExpandido
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Spacing.base),
                      for (final review in _minhasAvaliacoes)
                        ReviewCard(review: review, compact: true),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario(BuildContext context) {
    final formulario = AppCard(
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _minhasAvaliacoes.isEmpty ? 'Avaliar este comércio' : 'Avaliar de novo',
            style: AppText.h2(context),
          ),
          const SizedBox(height: 2.0),
          Text(
            _isGuest
                ? 'Entre na sua conta para avaliar este comércio.'
                : 'Sua nota ajuda outras pessoas a decidir.',
            style: AppText.secondary(context),
          ),
          const SizedBox(height: Spacing.base),
          _StarPicker(
            rating: _rating,
            onChanged: (nota) {
              setState(() => _rating = nota);
              _notifyUnsavedChanged();
            },
          ),
          const SizedBox(height: Spacing.base),
          AppFormField(
            controller: _commentController,
            label: 'Comentário (opcional)',
            hint: 'Conte como foi sua experiência...',
            maxLines: 3,
            maxLength: 1000,
            showIcon: false,
          ),
          const SizedBox(height: Spacing.base),
          AppButton(
            label: 'Enviar avaliação',
            variant: AppButtonVariant.primary,
            loading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );

    if (!_isGuest) return formulario;

    return Semantics(
      button: true,
      label: 'Avaliar este comércio. Requer entrar na conta.',
      child: GestureDetector(
        onTap: _mostrarParedeLogin,
        behavior: HitTestBehavior.opaque,
        child: AbsorbPointer(child: formulario),
      ),
    );
  }
}

class _HistoricoCarregando extends StatelessWidget {
  const _HistoricoCarregando();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevation: AppCardElevation.flat,
      bordered: false,
      padding: const EdgeInsets.all(Spacing.base),
      child: Row(
        children: [
          const SizedBox(
            width: 16.0,
            height: 16.0,
            child: CircularProgressIndicator(strokeWidth: 2, color: MfColor.brand),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              'Carregando suas avaliações...',
              style: AppText.secondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarPicker extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _StarPicker({required this.rating, required this.onChanged});

  static const _rotulos = ['Péssimo', 'Ruim', 'Regular', 'Bom', 'Excelente'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= 5; i++)
              SemanticTapArea(
                label: '$i ${i == 1 ? 'estrela' : 'estrelas'}',
                selected: rating == i,
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.sm),
                  child: Icon(
                    i <= rating ? AppIcons.starFill : AppIcons.star,
                    size: escalaIcone(context, 36.0),
                    color: i <= rating
                        ? MfColor.rating
                        : context.mapColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(
          height: escalaComTeto(context, 18.0),
          child: rating == 0
              ? null
              : Text(
                  _rotulos[rating - 1],
                  style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
