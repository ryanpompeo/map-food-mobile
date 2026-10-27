import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/features/auth/presentation/widgets/terms_checkbox.dart';
import 'package:map_food/features/guest/presentation/pages/documento_legal_page.dart';
import 'package:map_food/features/guest/presentation/pages/politica_privacidade_page.dart';
import 'package:map_food/features/guest/presentation/pages/termos_page.dart';

String _textoDe(WidgetTester tester) =>
    tester.widget<DocumentoLegalPage>(find.byType(DocumentoLegalPage)).markdown;

Future<void> _abrir(WidgetTester tester, Widget pagina) async {
  await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: pagina));
  await tester.pumpAndSettle();
}

void main() {
  group('termos de uso', () {
    testWidgets('têm título próprio e não misturam a política de dados', (tester) async {
      await _abrir(tester, const TermosPage());

      expect(find.text('Termos de Uso'), findsOneWidget);

      final texto = _textoDe(tester);
      expect(texto, contains('Isenção de Responsabilidade'));
      expect(texto, contains('Posição da Loja Aberta'));
      expect(texto, isNot(contains('Lei Geral de Proteção de Dados')));
      expect(texto, isNot(contains('Dados Coletados')));
    });
  });

  group('política de privacidade', () {
    testWidgets('tem título próprio e não repete as regras de uso', (tester) async {
      await _abrir(tester, const PoliticaPrivacidadePage());

      expect(find.text('Política de Privacidade'), findsOneWidget);

      final texto = _textoDe(tester);
      expect(texto, contains('Lei Geral de Proteção de Dados'));
      expect(texto, isNot(contains('Isenção de Responsabilidade')));
    });

    testWidgets('cobre o que o aplicativo passou a fazer', (tester) async {
      await _abrir(tester, const PoliticaPrivacidadePage());
      final texto = _textoDe(tester);

      expect(texto, contains('Confirmação de E-mail'));
      expect(texto, contains('Notificações no seu Aparelho'));
      expect(texto, contains('Favorita por perto'));
      expect(texto, contains('no máximo uma vez por dia'));
      expect(texto, contains('fora do backup automático do Android'));
    });

    testWidgets('não promete anonimato que o servidor não garante', (tester) async {
      await _abrir(tester, const PoliticaPrivacidadePage());
      final texto = _textoDe(tester);

      expect(texto, contains('em nenhuma tela do aplicativo'));
      expect(texto, isNot(contains('nunca a identidade de quem denunciou')));
    });
  });

  group('aceite no cadastro', () {
    Future<void> abrirCheckbox(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TermsCheckbox(value: false, onChanged: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('o link dos termos abre os termos', (tester) async {
      await abrirCheckbox(tester);

      await tester.tapOnText(find.textRange.ofSubstring('Termos de Uso'));
      await tester.pumpAndSettle();

      expect(find.byType(TermosPage), findsOneWidget);
      expect(find.byType(PoliticaPrivacidadePage), findsNothing);
    });

    testWidgets('o link da privacidade abre a política', (tester) async {
      await abrirCheckbox(tester);

      await tester.tapOnText(find.textRange.ofSubstring('Política de Privacidade'));
      await tester.pumpAndSettle();

      expect(find.byType(PoliticaPrivacidadePage), findsOneWidget);
      expect(find.byType(TermosPage), findsNothing);
    });
  });
}
