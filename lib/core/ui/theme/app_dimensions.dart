
/// Uso típico:
/// - [xs] entre um ícone e seu rótulo
/// - [sm] entre linhas de um mesmo bloco
/// - [md] padding interno de chip/campo
/// - [base] padding de card e gutter de lista
/// - [lg] margem lateral da tela
/// - [xl] entre seções
/// - [xxl]/[xxxl] respiro de topo/rodapé de tela
class Spacing {
  const Spacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
}

/// Raios (v2). Regra: quanto maior a superfície, maior o raio — e pílula
/// **só** em chip, badge e botão circular.
///
/// Pílula em tudo (botão, campo, card), como estava, achata a hierarquia: se
/// todo elemento tem a mesma forma, nenhum se destaca.
class Radii {
  const Radii._();

  /// Tag, badge, selo de categoria.
  static const sm = 8.0;

  /// Campo de formulário, botão secundário, thumbnail.
  static const md = 12.0;

  /// Botão primário, card de lista.
  static const lg = 16.0;

  /// Card grande, modal.
  static const xl = 20.0;

  /// Bottom sheet, hero card.
  static const xxl = 28.0;

  /// Só chip, badge e botão circular.
  static const pill = 999.0;
}

/// Duração e curva de animação. Uma escala curta evita que cada tela invente
/// seu próprio tempo — a inconsistência de ritmo é percebida como "lentidão"
/// mesmo quando cada animação isolada parece boa.
class Motion {
  const Motion._();

  /// Estados de componente: hover, seleção, cor, escala.
  static const fast = Duration(milliseconds: 150);

  /// Expansão, sheet, mudança de altura.
  static const medium = Duration(milliseconds: 220);

  /// Transição de página.
  static const slow = Duration(milliseconds: 300);
}

// ─────────────────────────── escalas legadas ───────────────────────────
// Mantidas com os valores originais enquanto a migração acontece: trocar
// esses números por dentro mexeria no espaçamento de todas as telas de uma
// vez, sem ninguém decidir tela a tela. Saem quando os lotes terminarem.

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;
}

class AppRadius {
  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const pill = 100.0;
}

class ImageSize {
  static const xs = 16.0;
  static const sm = 20.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 48.0;
  static const xxl = 64.0;
}

/// Tamanhos canônicos de ícone. Fora desta escala, nada.
/// [sm] inline em texto · [md] padrão de UI · [lg] navegação e ação
/// principal · [xl] empty state.
class AppIconSize {
  static const sm = 16.0;
  static const md = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
