import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/services/notification_service.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/features/reviews/data/models/denuncia_model.dart';
import 'package:map_food/features/reviews/data/services/denuncia_service.dart';

class ConsumerComplaintsPage extends StatefulWidget {
  const ConsumerComplaintsPage({super.key});

  @override
  State<ConsumerComplaintsPage> createState() => _ConsumerComplaintsPageState();
}

class _ConsumerComplaintsPageState extends State<ConsumerComplaintsPage> {
  final _denunciaService = DenunciaService();

  bool _isLoading = true;
  String? _errorMessage;
  List<DenunciaModel> _denuncias = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final session = await AuthStorage.getSession();
      if (session == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final denuncias = await _denunciaService.getMyComplaints(session.id);
      if (!mounted) return;
      setState(() {
        _denuncias = denuncias;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Não foi possível carregar suas denúncias.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Minhas Denúncias",
          style: AppText.subtitulo(context)
              .copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(LucideIcons.chevronLeft, color: ColorsPalette.redComponents),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents))
            : _errorMessage != null
                ? _ErrorState(message: _errorMessage!, onRetry: _carregar)
                : _denuncias.isEmpty
                    ? const _EmptyState()
                    : RefreshIndicator(
                        onRefresh: _carregar,
                        color: ColorsPalette.redComponents,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: _denuncias.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) => _DenunciaCard(
                            denuncia: _denuncias[index],
                            onCancelled: () => setState(() => _denuncias.removeAt(index)),
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _DenunciaCard extends StatefulWidget {
  final DenunciaModel denuncia;
  final VoidCallback onCancelled;

  const _DenunciaCard({required this.denuncia, required this.onCancelled});

  @override
  State<_DenunciaCard> createState() => _DenunciaCardState();
}

class _DenunciaCardState extends State<_DenunciaCard> {
  final _denunciaService = DenunciaService();
  bool _isCancelling = false;

  static const _motivoLabels = {
    'CONTEUDO_INAPROPRIADO': 'Conteúdo inapropriado',
    'FRAUDE_OU_GOLPE': 'Fraude ou golpe',
    'INFORMACOES_FALSAS': 'Informações falsas',
    'SPAM': 'Spam',
    'OUTRO': 'Outro',
  };

  // Cores semânticas da paleta (context.appColors), não mais hardcoded.
  ({String label, Color color}) _statusInfo(AppColorsExtension colors, String status) {
    switch (status) {
      case 'RESOLVIDA':
        return (label: 'Resolvida', color: colors.success);
      case 'EM_ANALISE':
        return (label: 'Em análise', color: colors.warning);
      case 'ARQUIVADA':
        return (label: 'Arquivada', color: colors.textSecondary);
      default:
        return (label: 'Pendente', color: colors.warning);
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _confirmarCancelamento() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Text('Cancelar denúncia?'),
        content: const Text('Essa denúncia será removida e não poderá ser recuperada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Voltar', style: TextStyle(color: context.appColors.textSecondary, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Confirmar', style: TextStyle(color: context.appColors.error, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    setState(() => _isCancelling = true);
    try {
      await _denunciaService.cancel(widget.denuncia.id);
      NotificationService.instance.success('Denúncia cancelada.');
      widget.onCancelled();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCancelling = false);
      NotificationService.instance.error('Não foi possível cancelar. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final denuncia = widget.denuncia;
    final status = _statusInfo(colors, denuncia.statusDenuncia);
    final podeCancel = denuncia.statusDenuncia == 'PENDENTE';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _motivoLabels[denuncia.motivo] ?? denuncia.motivo,
                  style: AppText.corpo(context).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  status.label,
                  style: AppText.legenda(context).copyWith(color: status.color, fontWeight: FontWeight.bold),
                ),
              ),
              // Só existe enquanto a denúncia estiver PENDENTE — some
              // sozinho assim que o status mudar (RESOLVIDA/ARQUIVADA não
              // podem mais ser canceladas, e o backend já rejeita com 409).
              if (podeCancel) ...[
                const SizedBox(width: 8.0),
                _isCancelling
                    ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : GestureDetector(
                        onTap: _confirmarCancelamento,
                        child: Icon(LucideIcons.trash2, size: 18, color: colors.error),
                      ),
              ],
            ],
          ),
          if (denuncia.descricao != null && denuncia.descricao!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              denuncia.descricao!,
              style: AppText.corpo(context).copyWith(color: Colors.grey.shade700, height: 1.4),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            _formatDate(denuncia.dataDenuncia),
            style: AppText.legenda(context).copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: ColorsPalette.redComponents.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(LucideIcons.flag, color: ColorsPalette.redComponents, size: 42),
            ),
            const SizedBox(height: 20),
            Text("Nenhuma denúncia registrada", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "As denúncias que você fizer aparecerão aqui.",
              textAlign: TextAlign.center,
              style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 48, color: ColorsPalette.greyText),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText)),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsPalette.redComponents,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
