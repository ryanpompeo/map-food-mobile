import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/interceptors/error_interceptor.dart';
import 'package:map_food/features/analytics/data/models/acesso_metricas.dart';
import 'package:map_food/features/analytics/data/services/acesso_service.dart';
import 'package:map_food/features/analytics/presentation/controllers/analytics_controller.dart';

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

      final pontos = pontosDeAcesso(resumo, AnalyticsRange.seteDias);

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

      final pontos = pontosDeAcesso(resumo, AnalyticsRange.trintaDias);

      expect(pontos, hasLength(6), reason: 'não cabem 30 colunas na tela de um celular');
      expect(pontos.fold<int>(0, (soma, p) => soma + p.value), 30,
          reason: 'agrupar não pode perder visita');
    });

    test('sem dado nenhum, o gráfico não recebe pontos', () {
      expect(pontosDeAcesso(AcessoResumo.vazio, AnalyticsRange.seteDias), isEmpty);
    });
  });
}
