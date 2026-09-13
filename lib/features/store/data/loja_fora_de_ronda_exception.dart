import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';

class LojaForaDeRondaException extends AppException {
  const LojaForaDeRondaException(this.status, super.message) : super(statusCode: 409);

  final StatusLoja status;
}
