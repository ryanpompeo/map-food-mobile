import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

/// O controle mais importante do app para o comerciante: abrir e fechar a
/// loja, e entender **num relance** se ela está sendo vista.
///
/// Três decisões de operação (não de estética) que este card resolve:
///
/// 1. **A ação virou botão, não interruptor.** O `Switch` do Material tem
///    ~40×24px de alvo real e nenhum rótulo do que vai acontecer; quem opera
///    isso está na rua, muitas vezes de uma mão só. Um botão de 52px dizendo
///    "Fechar loja" acerta na primeira e não deixa dúvida sobre o sentido do
///    toque — interruptor obriga a ler o estado atual para deduzir o efeito.
/// 2. **Aberta é uma superfície de alto contraste**, via
///    `selectedSurface`/`onSelectedSurface` (o mesmo par de chip e segmento
///    ativos). Antes era `Colors.black` fixo com texto `grey.shade400`: no
///    tema escuro o card sumia no fundo e o subtítulo caía abaixo do mínimo
///    de contraste.
/// 3. **A ronda de GPS é visível.** "Aberta" e "sendo localizada" são estados
///    diferentes — dá para estar aberta com o GPS negado, e a loja não
///    aparece no mapa de ninguém. O rodapé mostra quando a última posição
///    subiu e com que precisão, e [avisoPosicao] transforma a falha silenciosa
///    de envio em algo que a pessoa consegue ver e reagir.
class StoreStatusCard extends StatelessWidget {
  final bool aberta;

  /// Assinatura de GPS ativa, enviando posição ao servidor.
  final bool rastreioAtivo;

  /// Chamada em andamento (abrir/fechar) — bloqueia o botão e mostra spinner.
  final bool ocupado;

  /// Quando a última posição foi aceita pelo servidor.
  final DateTime? ultimaPosicaoEm;

  /// Raio de erro do GPS em metros, como reportado pelo aparelho.
  final double? precisaoMetros;

  /// Falha corrente do envio de posição (rede/servidor). `null` quando tudo
  /// está subindo normalmente.
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
    // Sobre a superfície invertida não dá para usar `textSecondary` (ele é
    // calibrado para o fundo da tela): o apoio vira o próprio conteúdo a 65%.
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
            // Sobre o card invertido, o vermelho de marca brigaria com a
            // superfície: `onBrand` dá o branco sólido que sempre lê ali.
            // Fechada, abrir é a ação principal da tela — vermelho.
            variant: aberta ? AppButtonVariant.onBrand : AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}

/// Selo "AO VIVO" com ponto pulsante — o vocabulário que todo app de entrega
/// usa para "isto está acontecendo agora". Sem o pulso, o selo parece um
/// rótulo estático e não comunica atividade.
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
          // RepaintBoundary: o pulso repinta 60x/s e não deve arrastar o
          // resto do card (que inclui texto e botão) junto.
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

/// Rodapé de dados da ronda: quando a posição subiu e com que precisão.
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

  /// "agora" cobre o intervalo mais comum (a posição sobe a cada poucos
  /// metros percorridos) — mostrar "há 4 s" ali só faria o número piscar sem
  /// dizer nada de novo.
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
          // `numeric` (tabular): "±12 m" e "há 3 min" trocam de valor no
          // lugar em vez de empurrar o texto lateralmente a cada atualização.
          style: AppText.numeric(context, size: 15).copyWith(color: corConteudo),
        ),
      ],
    );
  }
}

/// Faixa de aviso quando o envio de posição está falhando.
///
/// Antes essa falha era um `catch (_)` mudo: a loja aparecia como aberta e
/// "ao vivo" enquanto o servidor seguia com a posição de meia hora atrás.
class _AvisoPosicao extends StatelessWidget {
  final String mensagem;

  /// Sobre o card aberto (superfície invertida) a paleta de alerta precisa de
  /// outro fundo — o `dangerSurface` claro sumiria ali.
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
