import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/storage/cofre_seguro.dart';

CofreEmMemoria usarCofreEmMemoria() {
  final cofre = CofreEmMemoria();
  substituirCofre(cofre);
  addTearDown(restaurarCofre);
  return cofre;
}
