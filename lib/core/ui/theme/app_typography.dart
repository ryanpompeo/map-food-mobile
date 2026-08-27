import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Escala tipográfica do app (v2, Inter).
///
/// Três regras que valem para tudo aqui:
///
/// 1. **Título grande tem letter-spacing negativo.** Fonte grande com
///    espaçamento padrão parece esparramada; apertar de −0.4 a −1.0 é o que
///    dá o ar compacto de produto.
/// 2. **Botão tem letter-spacing zero.** Espaçamento positivo em botão é
///    assinatura de Material 2 e envelhece a tela na hora.
/// 3. **Estilo não carrega cor de marca.** Cada estilo resolve só a cor de
///    conteúdo (primário/secundário) a partir do tema; quem compõe decide o
///    resto. Um estilo com `color: Colors.white` embutido obriga todo call
///    site a sobrescrever — era o caso do `botao` antigo.
class AppText {
  const AppText._();

  /// Família única, declarada no `pubspec.yaml`. Enquanto os arquivos não
  /// estiverem em `assets/fonts/`, o Flutter cai na fonte do sistema sem
  /// quebrar — o app roda, só não fica com o desenho certo.
  static const family = 'Inter';

  // ───────────────────────────── display e títulos ─────────────────────────────

  /// 32/38 w700 — abertura de tela (o "Perfil", o "Bem-vindo de volta").
  static TextStyle display(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 32,
        height: 38 / 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: context.mapColors.textPrimary,
      );

  /// 24/30 w700 — título de tela.
  static TextStyle h1(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 24,
        height: 30 / 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: context.mapColors.textPrimary,
      );

  /// 20/26 w600 — título de seção.
  static TextStyle h2(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 20,
        height: 26 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        color: context.mapColors.textPrimary,
      );

  /// 16/22 w600 — título de card e de item de lista.
  static TextStyle title(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: context.mapColors.textPrimary,
      );

  // ────────────────────────────────── corpo ──────────────────────────────────

  /// 15/22 w400 — texto corrente.
  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: context.mapColors.textPrimary,
      );

  /// 15/22 w600 — o mesmo corpo, com ênfase (valor ao lado de rótulo).
  static TextStyle bodyStrong(BuildContext context) =>
      body(context).copyWith(fontWeight: FontWeight.w600);

  /// 13/18 w400 — apoio, subtítulo de item de lista.
  static TextStyle secondary(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: context.mapColors.textSecondary,
      );

  /// 12/16 w500 — metadado, rótulo de campo, legenda.
  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: context.mapColors.textSecondary,
      );

  /// 11/14 w600 caixa alta — rótulo de seção ("MINHA CONTA").
  static TextStyle overline(BuildContext context) => TextStyle(
        fontFamily: family,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: context.mapColors.textSecondary,
      );

  /// 15/20 w600 — rótulo de botão. **Sem cor**: quem monta o botão define,
  /// porque ela depende da variante (branco no primário, texto primário no
  /// secundário, marca no ghost).
  static TextStyle button(BuildContext context) => const TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600,
      );

  // ───────────────────────────────── números ─────────────────────────────────

  /// Métrica grande (o total do gráfico, o valor de um card de estatística).
  ///
  /// `tabularFigures` deixa todo dígito com a mesma largura — sem isso o
  /// número "pula" lateralmente quando o valor muda de 1 para 2, que é
  /// justamente o caso de um contador que atualiza.
  static TextStyle metric(BuildContext context, {double size = 28}) => TextStyle(
        fontFamily: family,
        fontSize: size,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: context.mapColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Número inline (nota, distância, contagem) — mesma largura de dígito,
  /// tamanho de corpo.
  static TextStyle numeric(BuildContext context, {double size = 13}) => TextStyle(
        fontFamily: family,
        fontSize: size,
        height: 18 / 13,
        fontWeight: FontWeight.w600,
        color: context.mapColors.textPrimary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ─────────────────────────── nomes legados (apelidos) ───────────────────────────
  // O app tem centenas de chamadas a estes nomes. Apontá-los para a escala
  // nova troca a tipografia inteira de uma vez, sem um mutirão de renomeação.
  // Saem conforme cada tela for migrada nos lotes seguintes.

  static TextStyle titulo(BuildContext context) => h1(context);

  static TextStyle subtitulo(BuildContext context) => h2(context);

  static TextStyle corpo(BuildContext context) => body(context);

  static TextStyle secundario(BuildContext context) => secondary(context);

  static TextStyle legenda(BuildContext context) => caption(context);

  static TextStyle destaque(BuildContext context) => caption(context).copyWith(
        fontWeight: FontWeight.w700,
        color: MfColor.brand,
        letterSpacing: 0.6,
      );

  /// Mantém a cor branca embutida do estilo antigo: há botões de fundo
  /// escuro que dependem dela implicitamente. O substituto correto é
  /// [button] (sem cor) — a troca acontece junto com o `AppButton` no lote 2.
  static TextStyle botao(BuildContext context) =>
      button(context).copyWith(color: ColorsPalette.white);
}
