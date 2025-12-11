class Categoria {
  final String nome;
  final String emoji;
  final int cor;  // Use Colors.red.value etc.

  Categoria({
    required this.nome,
    required this.emoji,
    required this.cor,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      nome: json['nome'],
      emoji: json['emoji'],
      cor: json['cor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'emoji': emoji,
      'cor': cor,
    };
  }
}
