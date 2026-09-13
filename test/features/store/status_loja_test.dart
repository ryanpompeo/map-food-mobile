import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';

StoreDto _loja({String statusLoja = 'ATIVA', int? segundosSemSinal}) => StoreDto(
      id: 7,
      nome: 'Carrinho do Zé',
      statusLoja: statusLoja,
      categoria: 'Lanches',
      categoriaIds: const [3],
      cep: '13000-000',
      latitude: -22.9068,
      longitude: -43.1729,
      segundosSemSinal: segundosSemSinal,
    );

void main() {
  group('StatusLoja.de', () {
    test('reconhece os três status da API', () {
      expect(StatusLoja.de('ATIVA'), StatusLoja.ativa);
      expect(StatusLoja.de('INATIVA'), StatusLoja.inativa);
      expect(StatusLoja.de('SUSPENSA'), StatusLoja.suspensa);
    });

    test('valor novo ou ausente vira desconhecido, nunca ATIVA por engano', () {
      expect(StatusLoja.de('EM_ANALISE'), StatusLoja.desconhecido);
      expect(StatusLoja.de(''), StatusLoja.desconhecido);
      expect(StatusLoja.de(null), StatusLoja.desconhecido);
    });
  });

  group('segundosSemSinal', () {
    test('loja em ronda traz a defasagem medida pela API', () {
      final loja = StoreDto.fromJson({'id': 6, 'statusLoja': 'ATIVA', 'segundosSemSinal': 120});

      expect(loja.segundosSemSinal, 120);
      expect(loja.emRonda, isTrue);
    });

    test('loja fixa vem sem defasagem e não está em ronda', () {
      final loja = StoreDto.fromJson({'id': 5, 'statusLoja': 'ATIVA', 'segundosSemSinal': null});

      expect(loja.segundosSemSinal, isNull);
      expect(loja.emRonda, isFalse);
    });

    test('resposta sem status assume loja fechada', () {
      expect(StoreDto.fromJson({'id': 5}).status, StatusLoja.inativa);
    });
  });

  group('cópias da loja', () {
    test('posição recém-enviada zera a defasagem e preserva o cadastro', () {
      final loja = _loja(segundosSemSinal: 300).comPosicao(-22.92, -43.19);

      expect(loja.latitude, -22.92);
      expect(loja.longitude, -43.19);
      expect(loja.segundosSemSinal, 0);
      expect(loja.cep, '13000-000');
      expect(loja.categoriaIds, [3]);
    });

    test('loja que sai de ATIVA deixa de estar em ronda, como na API', () {
      final fechada = _loja(segundosSemSinal: 60).comStatus(StatusLoja.inativa);
      final suspensa = _loja(segundosSemSinal: 60).comStatus(StatusLoja.suspensa);

      expect(fechada.status, StatusLoja.inativa);
      expect(fechada.segundosSemSinal, isNull);
      expect(suspensa.segundosSemSinal, isNull);
    });

    test('reafirmar ATIVA preserva a defasagem', () {
      expect(_loja(segundosSemSinal: 60).comStatus(StatusLoja.ativa).segundosSemSinal, 60);
    });
  });
}
