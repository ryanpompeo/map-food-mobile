// Arquivo: lib/models/store/user_review.dart

class UserReview {
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;

  UserReview({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

/// Repositório temporário em memória para salvar as avaliações da sessão.
/// Em um app real com backend, isso seria substituído por chamadas à sua API ou banco local (Hive/SQLite).
class ReviewRepository {
  // Mapa estático que liga o Nome (ou ID) da loja à Avaliação do usuário
  static final Map<String, UserReview> _avaliacoesSalvas = {};

  // Salva a avaliação
  static void salvarAvaliacao(String storeId, UserReview review) {
    _avaliacoesSalvas[storeId] = review;
  }

  // Busca a avaliação caso o usuário volte na tela
  static UserReview? buscarAvaliacao(String storeId) {
    return _avaliacoesSalvas[storeId];
  }
}
