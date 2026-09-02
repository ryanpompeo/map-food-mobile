import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

class StoreStatusCard extends StatelessWidget {
  final bool aberta;

  final bool rastreioAtivo;

  final bool ocupado;

  final DateTime? ultimaPosicaoEm;

  final double? precisaoMetros;

  final String? avisoPosicao;

  final VoidCallback? onToggle;

  const StoreStatusCard({
    super.key,
    required this.aberta,
    required this.rastreioAtivo,
    required this.ocupado,
    required this.onToggle,
    this.ultimaPosicaoEm,
    this.precisaoMetros,
    this.avisoPosicao,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

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
              Icon(
                aberta ? AppIcons.storefront : AppIcons.eyeSlash,
                size: AppIconSize.lg,
                color: conteudo,
              ),
              const Spacer(),
              if (aberta && rastreioAtivo) const _LiveBadge(),
            ],
          ),
          const SizedBox(height: Spacing.base),
          Text(
            aberta ? 'Loja aberta' : 'Loja fechada',
            style: AppText.h1(context).copyWith(color: conteudo),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            aberta
                ? 'Os clientes estão vendo você no mapa agora.'
                : 'Você não aparece no mapa enquanto estiver fechada.',
            style: AppText.secondary(context).copyWith(color: apoio, height: 1.4),
          ),

          if (aberta) ...[
            const SizedBox(height: Spacing.base),
            Divider(color: conteudo.withValues(alpha: 0.12), height: 1),
            const SizedBox(height: Spacing.md),
            _RondaInfo(
              rastreioAtivo: rastreioAtivo,
              ultimaPosicaoEm: ultimaPosicaoEm,
              precisaoMetros: precisaoMetros,
              corConteudo: conteudo,
              corApoio: apoio,
            ),
          ],

          if (avisoPosicao != null) ...[
            const SizedBox(height: Spacing.md),
            _AvisoPosicao(mensagem: avisoPosicao!, sobreSuperficieAtiva: aberta),
          ],

          const SizedBox(height: Spacing.lg),
          AppButton(
            label: aberta ? 'Fechar loja' : 'Abrir loja',
            icon: aberta ? AppIcons.eyeSlash : AppIcons.storefront,
            onPressed: onToggle,
            loading: ocupado,
            variant: aberta ? AppButtonVariant.onBrand : AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }
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
  final bool rastreioAtivo;
  final DateTime? ultimaPosicaoEm;
  final double? precisaoMetros;
  final Color corConteudo;
  final Color corApoio;

  const _RondaInfo({
    required this.rastreioAtivo,
    required this.ultimaPosicaoEm,
    required this.precisaoMetros,
    required this.corConteudo,
    required this.corApoio,
  });

  @override
  Widget build(BuildContext context) {
    if (!rastreioAtivo) {
      return Row(
        children: [
          Icon(AppIcons.warningCircle, size: AppIconSize.sm, color: corApoio),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'GPS desligado — sua loja fica parada no último ponto conhecido.',
              style: AppText.caption(context).copyWith(color: corApoio, height: 1.4),
            ),
          ),
        ],
      );
    }

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
