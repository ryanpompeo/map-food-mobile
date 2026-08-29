/// Nota média para exibição. `null` e `0` são loja **sem** avaliação — zero é
/// uma nota ruim, ausência de nota não é.
///
/// Separador decimal em vírgula, como o `RatingScorePill` já fazia: a mesma
/// nota aparecia como "4.5" no card da busca e "4,5" no selo da loja.
String formatRating(double? rating) {
  if (rating == null || rating == 0.0) return 'Novo';
  return rating.toStringAsFixed(1).replaceAll('.', ',');
}
