import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_network_image.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/empty_state.dart';
import 'package:map_food/features/denuncias/data/models/denuncia_recebida_model.dart';
import 'package:map_food/features/denuncias/data/services/denuncia_service.dart';

String textoDoPrazo(DateTime prazo) {
  final local = prazo.toLocal();
  final dia = local.day.toString().padLeft(2, '0');
  final mes = local.month.toString().padLeft(2, '0');
  final hora = local.hour.toString().padLeft(2, '0');
  final minuto = local.minute.toString().padLeft(2, '0');
  return '$dia/$mes às $hora:$minuto';
}

String dataCurta(DateTime? data) {
  if (data == null) return '';
  final local = data.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}

List<DenunciaRecebidaModel> ordenarParaResponder(
  List<DenunciaRecebidaModel> denuncias,
  DateTime agora,
) {
  final ordenadas = [...denuncias];
  ordenadas.sort((a, b) {
    final prioridade = (b.podeResponder(agora) ? 1 : 0) - (a.podeResponder(agora) ? 1 : 0);
    if (prioridade != 0) return prioridade;
    final dataA = a.dataDenuncia ?? DateTime.fromMillisecondsSinceEpoch(0);
    final dataB = b.dataDenuncia ?? DateTime.fromMillisecondsSinceEpoch(0);
    return dataB.compareTo(dataA);
  });
  return ordenadas;
}

class MerchantComplaintsPage extends StatefulWidget {
  final DenunciaService? servico;

  final DateTime Function()? agora;

  const MerchantComplaintsPage({super.key, this.servico, this.agora});

  @override
  State<MerchantComplaintsPage> createState() => _MerchantComplaintsPageState();
}

class _MerchantComplaintsPageState extends State<MerchantComplaintsPage> {
  late final DenunciaService _servico = widget.servico ?? DenunciaService();
  late final DateTime Function() _agora = widget.agora ?? DateTime.now;

  bool _carregando = true;
  String? _erro;
  List<DenunciaRecebidaModel> _denuncias = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final comercianteId = SessionStore.instance.userId;
      if (comercianteId == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final recebidas = await _servico.getRecebidas(comercianteId);
      if (!mounted) return;
      setState(() {
        _denuncias = ordenarParaResponder(recebidas, _agora());
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = 'Não foi possível carregar as denúncias';
      });
    }
  }

  Future<bool> _responder(DenunciaRecebidaModel denuncia, String texto) async {
    try {
      final atualizada = await _servico.responder(denuncia.id, texto);
      if (!mounted) return true;
      setState(() {
        _denuncias = [
          for (final d in _denuncias) if (d.id == denuncia.id) atualizada else d,
        ];
      });
      AppToast.success(context, 'Resposta enviada');
      return true;
    } on AppException catch (erro) {
      if (mounted) AppToast.error(context, erro.message);
      return false;
    } catch (_) {
      if (mounted) AppToast.error(context, 'Não foi possível enviar sua resposta');
      return false;
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
          'Denúncias recebidas',
          style: AppText.subtitulo(context)
              .copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
        ),
      ),
      body: SafeArea(child: _buildCorpo(context)),
    );
  }

  Widget _buildCorpo(BuildContext context) {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator(color: ColorsPalette.redComponents));
    }
    if (_erro != null) {
      return Center(
        child: EmptyState(
          icon: AppIcons.wifiSlash,
          title: 'Não foi possível carregar',
          description: _erro!,
          actionLabel: 'Tentar novamente',
          onAction: _carregar,
          tone: EmptyStateTone.error,
        ),
      );
    }
    if (_denuncias.isEmpty) {
      return const Center(
        child: EmptyState(
          icon: AppIcons.flag,
          title: 'Nenhuma denúncia recebida',
          description: 'Se alguém denunciar uma das suas lojas, ela aparece aqui',
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregar,
      color: ColorsPalette.redComponents,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _denuncias.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => CardDenunciaRecebida(
          denuncia: _denuncias[index],
          agora: _agora,
          onResponder: (texto) => _responder(_denuncias[index], texto),
        ),
      ),
    );
  }
}

class CardDenunciaRecebida extends StatefulWidget {
  final DenunciaRecebidaModel denuncia;

  final DateTime Function() agora;

  final Future<bool> Function(String texto) onResponder;

  const CardDenunciaRecebida({
    super.key,
    required this.denuncia,
    required this.agora,
    required this.onResponder,
  });

  @override
  State<CardDenunciaRecebida> createState() => _CardDenunciaRecebidaState();
}

class _CardDenunciaRecebidaState extends State<CardDenunciaRecebida> {
  final TextEditingController _texto = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _texto.text.trim();
    if (texto.isEmpty) {
      AppToast.error(context, 'Escreva sua resposta antes de enviar');
      return;
    }
    setState(() => _enviando = true);
    final enviou = await widget.onResponder(texto);
    if (!mounted) return;
    setState(() => _enviando = false);
    if (enviou) _texto.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final denuncia = widget.denuncia;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(denuncia.motivoLabel, style: AppText.legenda(context)),
                  ],
                ),
              ),
              if (dataCurta(denuncia.dataDenuncia).isNotEmpty)
                Text(dataCurta(denuncia.dataDenuncia), style: AppText.legenda(context)),
            ],
          ),
          if (denuncia.descricao != null && denuncia.descricao!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              denuncia.descricao!,
              style: AppText.corpo(context).copyWith(color: colors.secondaryText, height: 1.4),
            ),
          ],
          if (denuncia.itemConsumido != null || denuncia.dataConsumo != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              [
                if (denuncia.itemConsumido != null) 'Item: ${denuncia.itemConsumido}',
                if (denuncia.dataConsumo != null)
                  'Consumido em ${dataCurta(denuncia.dataConsumo)}',
              ].join(' · '),
              style: AppText.legenda(context),
            ),
          ],
          if (denuncia.fotoUrl != null && denuncia.fotoUrl!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AppNetworkImage(
                path: resolveImagemUrl(denuncia.fotoUrl),
                displayWidth: MediaQuery.sizeOf(context).width,
                height: 160.0,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          _buildResposta(context),
        ],
      ),
    );
  }

  Widget _buildResposta(BuildContext context) {
    final colors = context.mapColors;
    final denuncia = widget.denuncia;

    if (denuncia.jaRespondida) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sua resposta',
              style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(denuncia.respostaComerciante!, style: AppText.corpo(context)),
            if (denuncia.dataResposta != null) ...[
              const SizedBox(height: 2),
              Text(
                'Enviada em ${dataCurta(denuncia.dataResposta)}',
                style: AppText.legenda(context),
              ),
            ],
          ],
        ),
      );
    }

    if (!denuncia.abreDireitoDeResposta) {
      return Text(
        'Este motivo não abre direito de resposta: a moderação analisa e decide.',
        style: AppText.legenda(context),
      );
    }

    if (!denuncia.prazoAberto(widget.agora())) {
      return Text(
        'O prazo de resposta terminou em ${textoDoPrazo(denuncia.prazoResposta!)}.',
        style: AppText.legenda(context).copyWith(color: MfColor.danger),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Você tem até ${textoDoPrazo(denuncia.prazoResposta!)} para responder',
          style: AppText.legenda(context).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppFormField(
          controller: _texto,
          label: 'Sua resposta',
          hint: 'Conte o seu lado do que aconteceu',
          maxLines: 3,
          maxLength: 2000,
          showIcon: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: 'Enviar resposta',
          size: AppButtonSize.sm,
          loading: _enviando,
          onPressed: _enviar,
        ),
      ],
    );
  }
}
