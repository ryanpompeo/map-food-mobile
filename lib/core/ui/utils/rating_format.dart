String formatRating(double? rating) {
  if (rating == null || rating == 0.0) return 'Novo';
  return rating.toStringAsFixed(1);
}
