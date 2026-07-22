import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';

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
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Minhas Denúncias",
          style: AppText.subtitulo(context)
              .copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(PhosphorIconsRegular.caretLeft, color: ColorsPalette.redComponents),
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
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) => _DenunciaCard(denuncia: _denuncias[index]),
                        ),
                      ),
      ),
    );
  }
}

class _DenunciaCard extends StatelessWidget {
  final DenunciaModel denuncia;
  const _DenunciaCard({required this.denuncia});

  static const _motivoLabels = {
    'CONTEUDO_INAPROPRIADO': 'Conteúdo inapropriado',
    'FRAUDE_OU_GOLPE': 'Fraude ou golpe',
    'INFORMACOES_FALSAS': 'Informações falsas',
    'SPAM': 'Spam',
    'OUTRO': 'Outro',
  };

  ({String label, Color color}) _statusInfo(String status) {
    switch (status) {
      case 'RESOLVIDA':
        return (label: 'Resolvida', color: Colors.green);
      case 'EM_ANALISE':
        return (label: 'Em análise', color: Colors.amber.shade800);
      case 'ARQUIVADA':
        return (label: 'Arquivada', color: Colors.grey);
      default:
        return (label: 'Pendente', color: ColorsPalette.redComponents);
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

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(denuncia.statusDenuncia);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.mapColors.cardSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: context.mapColors.border),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      denuncia.lojaNome,
                      style: AppText.corpo(context).copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    // Sem override de cor: legenda() já resolve pra secondaryText.
                    Text(
                      _motivoLabels[denuncia.motivo] ?? denuncia.motivo,
                      style: AppText.legenda(context),
                    ),
                  ],
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
            ],
          ),
          if (denuncia.descricao != null && denuncia.descricao!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              denuncia.descricao!,
              style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText, height: 1.4),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          // Sem override de cor: legenda() já resolve pra secondaryText.
          Text(
            _formatDate(denuncia.dataDenuncia),
            style: AppText.legenda(context),
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
              child: const Icon(PhosphorIconsRegular.flag, color: ColorsPalette.redComponents, size: 42),
            ),
            const SizedBox(height: 20),
            Text("Nenhuma denúncia registrada", style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "As denúncias que você fizer aparecerão aqui.",
              textAlign: TextAlign.center,
              style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText),
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
            Icon(PhosphorIconsRegular.wifiSlash, size: 48, color: context.mapColors.iconMuted),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center, style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText)),
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
