import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/features/merchant/presentation/controllers/modo_ronda.dart';
import 'package:map_food/features/merchant/presentation/controllers/situacao_loja.dart';

class StoreStatusCard extends StatelessWidget {
  final SituacaoLoja situacao;

  final bool ocupado;

  final bool ligandoAcompanhamento;

  final DateTime? ultimaPosicaoEm;

  final double? precisaoMetros;

  final Duration? semSinalHa;

  final Duration? fechaEm;

  final String? avisoPosicao;

  final VoidCallback? onToggle;

  final VoidCallback? onAcompanhar;

  final ModoRonda modo;

  final DateTime? prazo;

  final bool fimProximo;

  final VoidCallback? onProrrogar;

  final VoidCallback? onTrocarModo;

  const StoreStatusCard({
    super.key,
    required this.situacao,
    required this.ocupado,
    required this.onToggle,
    this.ligandoAcompanhamento = false,
    this.ultimaPosicaoEm,
    this.precisaoMetros,
    this.semSinalHa,
    this.fechaEm,
    this.avisoPosicao,
    this.onAcompanhar,
    this.modo = ModoRonda.emMovimento,
    this.prazo,
    this.fimProximo = false,
    this.onProrrogar,
    this.onTrocarModo,
  });

  static String horaDe(DateTime quando) =>
      '${quando.hour.toString().padLeft(2, '0')}:${quando.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final aberta = situacao.aberta;
    final parada = modo == ModoRonda.parado && aberta;
    final (icone, titulo, subtitulo) = _cabecalho(situacao, parada: parada);

    final fundo = aberta ? colors.selectedSurface : colors.surface;
    final conteudo = aberta ? colors.onSelectedSurface : colors.textPrimary;
    final apoio = aberta ? conteudo.withValues(alpha: 0.65) : colors.textSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(Radii.xxl),
        border: aberta ? null : Border.all(color: colors.border),
        boxShadow: aberta ? AppElevation.floating : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: AppIconSize.lg, color: conteudo),
              const Spacer(),
              if (situacao == SituacaoLoja.transmitindo && !parada) const _LiveBadge(),
            ],
          ),
          const SizedBox(height: Spacing.base),
          Text(titulo, style: AppText.h1(context).copyWith(color: conteudo)),
          const SizedBox(height: Spacing.xs),
          Text(
            subtitulo,
            style: AppText.secondary(context).copyWith(color: apoio, height: 1.4),
          ),

          if (aberta) ...[
            const SizedBox(height: Spacing.base),
            Divider(color: conteudo.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: Spacing.md),
            _RondaInfo(
              situacao: situacao,
              ultimaPosicaoEm: ultimaPosicaoEm,
              precisaoMetros: precisaoMetros,
              semSinalHa: semSinalHa,
              fechaEm: fechaEm,
              corConteudo: conteudo,
              corApoio: apoio,
            ),
          ],

          if (aberta && prazo != null) ...[
            const SizedBox(height: Spacing.md),
            _PrazoDeFechamento(
              prazo: prazo!,
              fimProximo: fimProximo,
              onProrrogar: onProrrogar,
              corConteudo: conteudo,
              corApoio: apoio,
            ),
          ],

          if (avisoPosicao != null) ...[
            const SizedBox(height: Spacing.md),
            _AvisoPosicao(mensagem: avisoPosicao!, sobreSuperficieAtiva: aberta),
          ],

          if (situacao == SituacaoLoja.fixa) ...[
            const SizedBox(height: Spacing.lg),
            AppButton(
              label: 'Acompanhar minha posição',
              icon: AppIcons.navigationArrow,
              onPressed: ocupado ? null : onAcompanhar,
              loading: ligandoAcompanhamento,
            ),
          ],

          if (aberta && onTrocarModo != null) ...[
            const SizedBox(height: Spacing.sm),
            _TrocaDeModo(
              rotulo: parada ? 'Passar para em movimento' : 'Estou parado aqui',
              icone: parada ? AppIcons.navigationArrow : AppIcons.mapPin,
              cor: conteudo,
              onTap: ocupado ? null : onTrocarModo,
            ),
          ],

          if (situacao != SituacaoLoja.suspensa) ...[
            SizedBox(height: situacao == SituacaoLoja.fixa ? Spacing.sm : Spacing.lg),
            AppButton(
              label: aberta ? 'Fechar loja' : 'Abrir loja',
              icon: aberta ? AppIcons.eyeSlash : AppIcons.storefront,
              onPressed: ligandoAcompanhamento ? null : onToggle,
              loading: ocupado,
              variant: aberta ? AppButtonVariant.onBrand : AppButtonVariant.primary,
            ),
          ],
        ],
      ),
    );
  }

  static (IconData, String, String) _cabecalho(SituacaoLoja situacao, {bool parada = false}) =>
      switch (situacao) {
        SituacaoLoja.suspensa => (
            AppIcons.lock,
            'Loja suspensa',
            'A moderação suspendeu sua loja — fale com o suporte pra entender o motivo',
          ),
        SituacaoLoja.fechada => (
            AppIcons.eyeSlash,
            'Loja fechada',
            'Você não aparece no mapa enquanto estiver fechada',
          ),
        _ when parada => (
            AppIcons.mapPin,
            'Loja aberta neste ponto',
            'Os clientes veem você parado aqui',
          ),
        _ => (
            AppIcons.storefront,
            'Loja aberta',
            'Os clientes estão vendo você no mapa agora',
          ),
      };
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: MfColor.brand,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundary(
            child: FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.25).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: const SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: ColorsPalette.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.xs + 1),
          Text(
            'AO VIVO',
            style: AppText.overline(context).copyWith(
              color: ColorsPalette.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RondaInfo extends StatelessWidget {
  final SituacaoLoja situacao;
  final DateTime? ultimaPosicaoEm;
  final double? precisaoMetros;
  final Duration? semSinalHa;
  final Duration? fechaEm;
  final Color corConteudo;
  final Color corApoio;

  const _RondaInfo({
    required this.situacao,
    required this.ultimaPosicaoEm,
    required this.precisaoMetros,
    required this.semSinalHa,
    required this.fechaEm,
    required this.corConteudo,
    required this.corApoio,
  });

  @override
  Widget build(BuildContext context) => switch (situacao) {
        SituacaoLoja.transmitindo => _metricas(),
        SituacaoLoja.semSinal => _linha(context, AppIcons.wifiSlash, _textoSemSinal()),
        SituacaoLoja.iniciando => _linha(context, AppIcons.gpsFix, 'Obtendo sua posição…'),
        _ => _linha(context, AppIcons.mapPin, 'Posição fixa — os clientes veem o ponto do cadastro'),
      };

  Widget _linha(BuildContext context, IconData icone, String texto) {
    return Row(
      children: [
        Icon(icone, size: AppIconSize.sm, color: corApoio),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            texto,
            style: AppText.caption(context).copyWith(color: corApoio, height: 1.4),
          ),
        ),
      ],
    );
  }

  String _textoSemSinal() {
    final desde = semSinalHa;
    final restante = fechaEm;
    if (desde == null || restante == null) {
      return 'Sem sinal — os clientes veem o último ponto enviado';
    }
    return 'Sem sinal ${_ha(desde)} — se não voltar, a loja fecha sozinha ${_prazo(restante)}';
  }

  static String _ha(Duration desde) =>
      desde.inMinutes < 1 ? 'há menos de 1 min' : 'há ${desde.inMinutes} min';

  static String _prazo(Duration restante) {
    if (restante == Duration.zero) return 'a qualquer momento';
    return 'em ${(restante.inSeconds / 60).ceil()} min';
  }

  Widget _metricas() {
    return Row(
      children: [
        Expanded(
          child: _Metrica(
            icone: AppIcons.broadcast,
            rotulo: 'Posição enviada',
            valor: _tempoRelativo(ultimaPosicaoEm),
            corConteudo: corConteudo,
            corApoio: corApoio,
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: _Metrica(
            icone: AppIcons.crosshair,
            rotulo: 'Precisão',
            valor: precisaoMetros == null ? '—' : '±${precisaoMetros!.round()} m',
            corConteudo: corConteudo,
            corApoio: corApoio,
          ),
        ),
      ],
    );
  }

  static String _tempoRelativo(DateTime? quando) {
    if (quando == null) return 'aguardando';
    final segundos = DateTime.now().difference(quando).inSeconds;
    if (segundos < 60) return 'agora';
    final minutos = segundos ~/ 60;
    if (minutos < 60) return 'há $minutos min';
    final horas = minutos ~/ 60;
    return 'há $horas h';
  }
}

class _Metrica extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  final Color corConteudo;
  final Color corApoio;

  const _Metrica({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.corConteudo,
    required this.corApoio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icone, size: 14, color: corApoio),
            const SizedBox(width: Spacing.xs + 2),
            Expanded(
              child: Text(
                rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption(context).copyWith(color: corApoio),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.numeric(context, size: 15).copyWith(color: corConteudo),
        ),
      ],
    );
  }
}

class _AvisoPosicao extends StatelessWidget {
  final String mensagem;

  final bool sobreSuperficieAtiva;

  const _AvisoPosicao({required this.mensagem, required this.sobreSuperficieAtiva});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fundo = sobreSuperficieAtiva
        ? MfColor.warning.withValues(alpha: 0.18)
        : (isDark ? MfColor.dangerSurfaceDark : MfColor.dangerSurface);
    final conteudo = sobreSuperficieAtiva
        ? context.mapColors.onSelectedSurface
        : MfColor.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.warningCircle, size: AppIconSize.md, color: conteudo),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              mensagem,
              style: AppText.caption(context).copyWith(color: conteudo, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrocaDeModo extends StatelessWidget {
  final String rotulo;

  final IconData icone;

  final Color cor;

  final VoidCallback? onTap;

  const _TrocaDeModo({
    required this.rotulo,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: AppIconSize.sm, color: cor),
              const SizedBox(width: Spacing.sm),
              Text(
                rotulo,
                style: AppText.button(context).copyWith(color: cor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrazoDeFechamento extends StatelessWidget {
  final DateTime prazo;

  final bool fimProximo;

  final VoidCallback? onProrrogar;

  final Color corConteudo;

  final Color corApoio;

  const _PrazoDeFechamento({
    required this.prazo,
    required this.fimProximo,
    required this.onProrrogar,
    required this.corConteudo,
    required this.corApoio,
  });

  @override
  Widget build(BuildContext context) {
    final hora = StoreStatusCard.horaDe(prazo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.clock, size: AppIconSize.sm, color: corApoio),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                'Aberta até as $hora',
                style: AppText.bodyStrong(context).copyWith(color: corConteudo),
              ),
            ),
          ],
        ),
        if (fimProximo && onProrrogar != null) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            'Ela fecha sozinha às $hora',
            style: AppText.caption(context).copyWith(color: corApoio, height: 1.3),
          ),
          const SizedBox(height: Spacing.xs),
          _TrocaDeModo(
            rotulo: 'Ficar mais 2 horas',
            icone: AppIcons.clock,
            cor: corConteudo,
            onTap: onProrrogar,
          ),
        ],
      ],
    );
  }
}
