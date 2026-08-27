import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
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
      final consumidorId = SessionStore.instance.userId;
      if (consumidorId == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final denuncias = await _denunciaService.getMyComplaints(consumidorId);
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
          icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents))
            : _errorMessage != null
                // Estas duas telas tinham cópias privadas de "vazio" e
                // "erro", cada uma com seu próprio tamanho de ícone e botão.
                // Agora usam o EmptyState compartilhado.
                ? Center(
                    child: EmptyState(
                      icon: AppIcons.wifiSlash,
                      title: 'Não foi possível carregar',
                      description: _errorMessage!,
                      actionLabel: 'Tentar novamente',
                      onAction: _carregar,
                      tone: EmptyStateTone.error,
                    ),
                  )
                : _denuncias.isEmpty
                    ? const Center(
                        child: EmptyState(
                          icon: AppIcons.flag,
                          title: 'Nenhuma denúncia registrada',
                          description: 'As denúncias que você fizer aparecerão aqui.',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _carregar,
                        color: ColorsPalette.redComponents,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: _denuncias.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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
                  borderRadius: BorderRadius.circular(AppRadius.pill),
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

