import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/features/consumer/presentation/controllers/activity_summary.dart';

/// `resumirAtividade` monta a série do gráfico do perfil do consumidor a
/// partir das datas das avaliações. É a única lógica não-visual criada no
/// redesign e a mais fácil de errar em silêncio: um off-by-one na janela
/// desloca a curva inteira, e "parece certo" numa conferência a olho.
///
/// A função lê `DateTime.now()` internamente, então todos os casos montam as
/// datas em relação a hoje. As datas usam meio-dia de propósito: somar ou
/// subtrair dias a partir de 12:00 cai sempre no dia de calendário
/// pretendido, mesmo que o fuso mude em uma hora no meio do intervalo.
void main() {
  DateTime hoje() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day, 12);
  }

  DateTime diasAtras(int dias) => hoje().subtract(Duration(days: dias));

  DateTime mesesAtras(int meses) {
    final base = hoje();
    // Dia 15 pra não esbarrar em mês curto (31 de março menos um mês não
    // existe em fevereiro e o DateTime "transborda" pra março de novo).
    return DateTime(base.year, base.month - meses, 15, 12);
  }

  group('período de uma semana', () {
    test('devolve sete baldes, um por dia', () {
      final resumo = resumirAtividade(const [], ActivityPeriod.semana);

      expect(resumo.points, hasLength(7));
    });

    test('conta a avaliação de hoje no último balde', () {
      final resumo = resumirAtividade([hoje()], ActivityPeriod.semana);

      expect(resumo.points.last.value, 1);
      expect(resumo.total, 1);
    });

    test('posiciona a avaliação no dia certo da janela', () {
      // A janela vai de hoje-6 até hoje, então três dias atrás é o índice 3.
      final resumo = resumirAtividade([diasAtras(3)], ActivityPeriod.semana);

      expect(resumo.points[3].value, 1);
      expect(resumo.points.where((p) => p.value > 0), hasLength(1));
    });

    test('inclui o limite inferior da janela (hoje - 6)', () {
      final resumo = resumirAtividade([diasAtras(6)], ActivityPeriod.semana);

      expect(resumo.points.first.value, 1);
      expect(resumo.total, 1);
    });

    test('exclui o dia imediatamente anterior à janela (hoje - 7)', () {
      final resumo = resumirAtividade([diasAtras(7)], ActivityPeriod.semana);

      expect(resumo.total, 0);
      // Cai no período de comparação, então vira base do delta em vez de
      // simplesmente sumir.
      expect(resumo.deltaPercentual, -100);
    });

    test('ignora data no futuro', () {
      final amanha = hoje().add(const Duration(days: 1));

      final resumo = resumirAtividade([amanha], ActivityPeriod.semana);

      expect(resumo.total, 0);
      expect(resumo.points.every((p) => p.value == 0), isTrue);
    });

    test('acumula mais de uma avaliação no mesmo dia', () {
      final resumo = resumirAtividade(
        [diasAtras(2), diasAtras(2), diasAtras(2)],
        ActivityPeriod.semana,
      );

      expect(resumo.points[4].value, 3);
      expect(resumo.total, 3);
    });
  });

  group('período de um mês', () {
    test('devolve seis baldes de cinco dias', () {
      final resumo = resumirAtividade(const [], ActivityPeriod.mes);

      expect(resumo.points, hasLength(6));
    });

    test('agrupa dias do mesmo balde de cinco dias', () {
      // A janela vai de hoje-29 até hoje; os dias 29..25 atrás formam o
      // primeiro balde.
      final resumo = resumirAtividade(
        [diasAtras(29), diasAtras(25)],
        ActivityPeriod.mes,
      );

      expect(resumo.points.first.value, 2);
      expect(resumo.total, 2);
    });

    test('separa o dia seguinte no balde seguinte', () {
      final resumo = resumirAtividade([diasAtras(24)], ActivityPeriod.mes);

      expect(resumo.points[1].value, 1);
      expect(resumo.points.first.value, 0);
    });

    test('põe a avaliação de hoje no último balde', () {
      final resumo = resumirAtividade([hoje()], ActivityPeriod.mes);

      expect(resumo.points.last.value, 1);
    });

    test('rotula os baldes com dia/mês', () {
      final resumo = resumirAtividade(const [], ActivityPeriod.mes);
      final inicioJanela = diasAtras(29);

      expect(resumo.points.first.label, '${inicioJanela.day}/${inicioJanela.month}');
    });
  });

  group('período de um ano', () {
    test('devolve doze baldes mensais', () {
      final resumo = resumirAtividade(const [], ActivityPeriod.ano);

      expect(resumo.points, hasLength(12));
    });

    test('conta o mês corrente no último balde', () {
      final primeiroDiaDesteMes = DateTime(hoje().year, hoje().month, 1, 12);

      final resumo = resumirAtividade([primeiroDiaDesteMes], ActivityPeriod.ano);

      expect(resumo.points.last.value, 1);
      expect(resumo.total, 1);
    });

    test('inclui o limite inferior da janela (11 meses atrás)', () {
      final resumo = resumirAtividade([mesesAtras(11)], ActivityPeriod.ano);

      expect(resumo.points.first.value, 1);
      expect(resumo.total, 1);
    });

    test('exclui o mês imediatamente anterior à janela (12 meses atrás)', () {
      final resumo = resumirAtividade([mesesAtras(12)], ActivityPeriod.ano);

      expect(resumo.total, 0);
      expect(resumo.deltaPercentual, -100);
    });

    test('rotula os baldes com a inicial do mês', () {
      const iniciais = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

      final resumo = resumirAtividade(const [], ActivityPeriod.ano);

      expect(resumo.points.last.label, iniciais[hoje().month - 1]);
    });
  });

  group('variação percentual', () {
    test('é nula quando o período anterior não teve nada', () {
      // Sem base de comparação não existe percentual — mostrar "+100%" sobre
      // zero seria inventar leitura.
      final resumo = resumirAtividade([hoje()], ActivityPeriod.semana);

      expect(resumo.deltaPercentual, isNull);
    });

    test('é nula quando não há avaliação nenhuma', () {
      final resumo = resumirAtividade(const [], ActivityPeriod.semana);

      expect(resumo.total, 0);
      expect(resumo.deltaPercentual, isNull);
    });

    test('dobrar em relação ao período anterior dá +100%', () {
      final resumo = resumirAtividade(
        [diasAtras(1), diasAtras(2), diasAtras(8)],
        ActivityPeriod.semana,
      );

      expect(resumo.total, 2);
      expect(resumo.deltaPercentual, 100);
    });

    test('cair pela metade dá -50%', () {
      final resumo = resumirAtividade(
        [diasAtras(1), diasAtras(8), diasAtras(9)],
        ActivityPeriod.semana,
      );

      expect(resumo.total, 1);
      expect(resumo.deltaPercentual, -50);
    });

    test('arredonda a fração para o inteiro mais próximo', () {
      // 1 contra 3 → -66,67% → -67%.
      final resumo = resumirAtividade(
        [diasAtras(1), diasAtras(8), diasAtras(9), diasAtras(10)],
        ActivityPeriod.semana,
      );

      expect(resumo.deltaPercentual, -67);
    });

    test('ignora o que é anterior às duas janelas', () {
      // 20 dias atrás está fora tanto da semana atual (0-6) quanto da
      // anterior (7-13), então não vira base de comparação.
      final resumo = resumirAtividade(
        [hoje(), diasAtras(20)],
        ActivityPeriod.semana,
      );

      expect(resumo.total, 1);
      expect(resumo.deltaPercentual, isNull);
    });
  });
}
