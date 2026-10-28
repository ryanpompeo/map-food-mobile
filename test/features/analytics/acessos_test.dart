import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/analytics/data/models/acesso_metricas.dart';
import 'package:map_food/features/analytics/data/relatorio_csv.dart';
import 'package:map_food/features/analytics/data/services/acesso_service.dart';
import 'package:map_food/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';

import '../../support/api_falsa.dart';

AcessoService _servicoCom(ApiFalsa api) => AcessoService(
      client: ApiClient(
        dio: Dio(BaseOptions(baseUrl: 'http://test.local'))
          ..httpClientAdapter = api
          ..interceptors.add(ErrorInterceptor()),
      ),
    );

AcessoMetricas _metricas(List<(String, int)> dias) => AcessoMetricas.fromJson({
      'totalAcessos': dias.fold(0, (soma, d) => soma + d.$2),
      'porDia': [
        for (final dia in dias) {'data': dia.$1, 'quantidade': dia.$2},
      ],
    });

void main() {
  group('serviço', () {
    test('pede as métricas da loja com as datas no formato do servidor', () async {
      final api = ApiFalsa();
      api.responder('GET', '/lojas/7/acessos', 200,
          jsonEncode({'totalAcessos': 3, 'porDia': [
            {'data': '2026-10-27', 'quantidade': 3}
          ]}));

      final metricas = await _servicoCom(api).buscarMetricas(
        7,
        inicio: DateTime(2026, 10, 22),
        fim: DateTime(2026, 10, 28),
      );

      final chamada = api.doMetodo('GET').single;
      expect(chamada.path, '/lojas/7/acessos');
      expect(chamada.queryParameters['dataInicio'], '2026-10-22');
      expect(chamada.queryParameters['dataFim'], '2026-10-28');
      expect(metricas.totalAcessos, 3);
      expect(metricas.porDia.single.data, DateTime(2026, 10, 27));
    });

    test('resposta sem a série diária não quebra o modelo', () {
      final metricas = AcessoMetricas.fromJson({'totalAcessos': 10});

      expect(metricas.totalAcessos, 10);
      expect(metricas.porDia, isEmpty);
    });
  });

  group('soma de lojas', () {
    test('o mesmo dia de duas lojas vira um ponto só', () {
      final resumo = AnalyticsController.somarAcessos([
        _metricas([('2026-10-27', 3), ('2026-10-28', 1)]),
        _metricas([('2026-10-27', 2)]),
      ]);

      expect(resumo.total, 6);
      expect(resumo.porDia.map((d) => d.quantidade), [5, 1]);
      expect(resumo.indisponivel, isFalse);
    });

    test('quando nenhuma loja respondeu, a tela precisa saber', () {
      expect(AnalyticsController.somarAcessos(null).indisponivel, isTrue);
      expect(AnalyticsController.somarAcessos([]).total, 0);
    });

    test('os dias saem em ordem, mesmo chegando trocados', () {
      final resumo = AnalyticsController.somarAcessos([
        _metricas([('2026-10-28', 1), ('2026-10-26', 4)]),
      ]);

      expect(resumo.porDia.first.data, DateTime(2026, 10, 26));
      expect(resumo.porDia.last.data, DateTime(2026, 10, 28));
    });
  });

  group('pontos do gráfico', () {
    test('em 7 dias, um ponto por dia', () {
      final resumo = AnalyticsController.somarAcessos([
        _metricas([
          for (var dia = 22; dia <= 28; dia++) ('2026-10-$dia', dia),
        ]),
      ]);

      final pontos = pontosDeAcesso(resumo, 7);

      expect(pontos, hasLength(7));
      expect(pontos.first.label, '22/10');
      expect(pontos.last.value, 28);
    });

    test('em 30 dias, os dias viram seis blocos somados', () {
      final resumo = AnalyticsController.somarAcessos([
        _metricas([
          for (var dia = 1; dia <= 30; dia++)
            ('2026-10-${dia.toString().padLeft(2, '0')}', 1),
        ]),
      ]);

      final pontos = pontosDeAcesso(resumo, 30);

      expect(pontos, hasLength(6), reason: 'não cabem 30 colunas na tela de um celular');
      expect(pontos.fold<int>(0, (soma, p) => soma + p.value), 30,
          reason: 'agrupar não pode perder visita');
    });

    test('sem dado nenhum, o gráfico não recebe pontos', () {
      expect(pontosDeAcesso(AcessoResumo.vazio, 7), isEmpty);
    });
  });

  group('média mensal', () {
    test('monta os 12 meses, com os vazios no lugar', () {
      final meses = avaliacoesPorMes(
        [
          AvaliacaoModel(id: 1, nota: 5, dataAvaliacao: '2026-10-02T10:00:00'),
          AvaliacaoModel(id: 2, nota: 4, dataAvaliacao: '2026-10-20T10:00:00'),
          AvaliacaoModel(id: 3, nota: 2, dataAvaliacao: '2026-08-05T10:00:00'),
        ],
        DateTime(2026, 10, 28),
      );

      expect(meses, hasLength(12));
      expect(meses.last.mes, DateTime(2026, 10));
      expect(meses.last.quantidade, 2);
      expect(meses.last.media, 4.5);

      final setembro = meses[meses.length - 2];
      expect(setembro.quantidade, 0);
      expect(setembro.media, isNull,
          reason: 'mês sem avaliação não tem média, e média zero seria mentira');
    });

    test('avaliação sem data não entra na conta', () {
      final meses = avaliacoesPorMes(
        [AvaliacaoModel(id: 1, nota: 5)],
        DateTime(2026, 10, 28),
      );

      expect(meses.every((m) => m.quantidade == 0), isTrue);
    });

    test('o gráfico recebe um ponto por mês, com a sigla do mês', () {
      final meses = avaliacoesPorMes(const [], DateTime(2026, 10, 28));
      final pontos = pontosPorMes(meses);

      expect(pontos, hasLength(12));
      expect(pontos.last.label, 'out');
      expect(pontos.first.label, 'nov');
    });
  });

  group('relatório em CSV', () {
    AnalyticsSnapshot comDados() => AnalyticsSnapshot(
          distribuicaoNotas: const [RatingBucket(nota: 5, quantidade: 2)],
          mediaAvaliacao: 4.5,
          totalAvaliacoes: 2,
          denuncias: const DenunciaResumo(
            total: 1,
            emAberto: 1,
            encerradas: 0,
            deltaPercentual: null,
            porMotivo: [MotivoDenuncia(label: 'Spam', quantidade: 1)],
          ),
          acessos: AnalyticsController.somarAcessos([
            _metricas([('2026-10-27', 3), ('2026-10-28', 2)]),
          ]),
          porMes: avaliacoesPorMes(
            [AvaliacaoModel(id: 1, nota: 5, dataAvaliacao: '2026-10-02T10:00:00')],
            DateTime(2026, 10, 28),
          ),
        );

    test('traz resumo, visitas por dia, meses e motivos', () {
      final csv = relatorioCsv(
        snapshot: comDados(),
        inicio: DateTime(2026, 10, 22),
        fim: DateTime(2026, 10, 28),
        escopo: 'LOJA DA TATI',
      );

      expect(csv, contains('Escopo;LOJA DA TATI'));
      expect(csv, contains('Período;22/10/2026 a 28/10/2026'));
      expect(csv, contains('Total de visitas;5'));
      expect(csv, contains('Média das avaliações;4,5'));
      expect(csv, contains('2026-10-27;3'));
      expect(csv, contains('10/2026;1;5,0'));
      expect(csv, contains('Spam;1'));
    });

    test('o que não carregou aparece como não carregou, não como zero', () {
      final csv = relatorioCsv(
        snapshot: const AnalyticsSnapshot(
          distribuicaoNotas: [],
          mediaAvaliacao: null,
          totalAvaliacoes: 0,
          denuncias: DenunciaResumo.naoCarregou,
          acessos: AcessoResumo.naoCarregou,
        ),
        inicio: DateTime(2026, 10, 22),
        fim: DateTime(2026, 10, 28),
        escopo: 'todas as lojas',
      );

      expect(csv, contains('Total de visitas;não carregou'));
      expect(csv, contains('Denúncias no período;não carregou'));
      expect(csv, contains('Média das avaliações;sem avaliação'));
    });

    test('o nome do arquivo diz o período', () {
      expect(
        nomeDoArquivoCsv(DateTime(2026, 10, 22), DateTime(2026, 10, 28)),
        'mapfood-2026-10-22-a-2026-10-28.csv',
      );
    });
  });
}
