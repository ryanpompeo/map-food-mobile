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


class ReviewRepository {
 
  static final Map<String, UserReview> _avaliacoesSalvas = {};

  
  static void salvarAvaliacao(String storeId, UserReview review) {
    _avaliacoesSalvas[storeId] = review;
  }

  static UserReview? buscarAvaliacao(String storeId) {
    return _avaliacoesSalvas[storeId];
  }
}
