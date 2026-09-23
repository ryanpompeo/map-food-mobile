import 'package:map_food/core/notificacoes/notificacoes.dart';

typedef Aviso = Future<void> Function(String motivo);

class AvisosDaLoja {
  const AvisosDaLoja._();

  static const int saiuDoMapaId = 7301;
  static const int fechouNoHorarioId = 7302;

  static Future<void> saiuDoMapa(String motivo) => Notificacoes.mostrar(
        titulo: 'Sua loja saiu do mapa',
        texto: motivo,
        id: saiuDoMapaId,
      );

  static Future<void> fechouNoHorario(String motivo) => Notificacoes.mostrar(
        titulo: 'Loja fechada',
        texto: motivo,
        id: fechouNoHorarioId,
      );
}
