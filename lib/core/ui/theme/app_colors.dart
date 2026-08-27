import 'package:flutter/material.dart';

class MfColor {
  const MfColor._();

  /// Vermelho MapFood. Só para ação e estado ativo, nunca como fundo de área.
  static const brand = Color(0xFFD6011B);

  /// [brand] escurecido para o estado pressionado de superfícies de marca.
  static const brandPressed = Color(0xFFB00117);

  /// Fundo suave de marca: chip selecionado, badge, realce de seleção.
  /// No tema escuro use [brandSurfaceDark].
  static const brandSurface = Color(0xFFFDECEE);
  static const brandSurfaceDark = Color(0x24D6011B); // brand @ 14%

  /// Preto azulado da marca. É a cor de texto primário no tema claro e o
  /// fundo dos CTAs "neutros fortes" (o botão preto de Sair, os pins do mapa).
  static const ink = Color(0xFF12172A);

  /// Amarelo de nota/estrela.
  static const rating = Color(0xFFF5A623);

  /// Variante escurecida de [rating] para texto sobre fundo amarelo suave —
  /// [rating] puro não passa em contraste nesse par.
  static const ratingText = Color(0xFF8A5300);

  static const success = Color(0xFF12A150);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFD6011B);

  /// Fundo de ação destrutiva (botão "Excluir conta").
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerSurfaceDark = Color(0x24D6011B);

  /// Ponto de localização do usuário no mapa.
  static const userDot = Color(0xFF3B82F6);
}

/// Paleta legada. Continua valendo enquanto a migração para [MfColor] e
/// `context.mapColors` acontece lote a lote — os valores abaixo já apontam
/// para os tokens novos onde há equivalente exato, então quem ainda usa esta
/// classe recebe as cores corretas de graça.
class ColorsPalette {
  static const black = Colors.black;
  static const white = Colors.white;
  static const transparent = Colors.transparent;

  static const blackDetails = MfColor.ink;

  /// Cinza de apoio no tema escuro → `textSecondary` escuro da escala nova.
  static const greyDetails = Color(0xFF9BA1AC);

  /// Texto secundário no tema claro → `textSecondary` claro da escala nova.
  /// Escurecido junto com o token (era `#6B7280`, que rendia 4,39:1 sobre
  /// `surfaceAlt` e reprovava no AA) para os dois não divergirem.
  static const greyText = Color(0xFF4E535D);
  static const blackText = Colors.black;

  static const offWhite = Color(0xffF8FAFC);

  /// Fundo de tela do tema claro. Continua branco: o degrau de contraste
  /// agora vem de `surfaceAlt` (#F3F4F5), não de escurecer o fundo.
  static const whiteBackground = Colors.white;

  static const blackComponents = MfColor.ink;
  static const redComponents = MfColor.brand;
  static const redComponentsIcon = Color(0xFFE33E33);
  static const greyComponents = Color.fromARGB(255, 59, 61, 64);

  /// `--vermelho-degrade-3` da web. Cor de apoio para gradiente de hero —
  /// nunca como fundo de superfície.
  static const redDegrade3 = Color(0xffC33B35);

  /// Amarelo de nota/estrela. Antes cada tela escolhia um tom do `Colors.amber`
  /// do Material (shade400 no carrossel, shade500 nos badges, shade600 na
  /// lista de avaliações...), o que deixava a mesma estrela com um amarelo
  /// diferente em cada card. Valor único do Design System.
  static const ratingStar = MfColor.rating;

  /// Variante escurecida de [ratingStar] para *texto* sobre o fundo amarelo
  /// translúcido do pill de nota — [ratingStar] puro não passa em contraste
  /// nesse par (era `Colors.amber.shade900` antes, pelo mesmo motivo).
  static const ratingStarText = MfColor.ratingText;
}
