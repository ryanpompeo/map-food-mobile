import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/core/ui/widgets/logout_dialog.dart';
import 'package:map_food/features/settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reprodução do relato "toco em Excluir conta / Sair da conta e nada
/// aparece". Monta as telas de verdade e toca nos itens — sem API, porque o
/// que está sendo testado é a abertura do diálogo, não a chamada de rede.
void main() {
  setUp(() async {
    // O seletor de tema da tela de Configurações lê o ThemeController, que o
    // `main()` do app inicializa antes do runApp.
    SharedPreferences.setMockInitialValues({});
    await ThemeController.load();
  });

  Widget montar(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: child,
      );

  testWidgets('tocar em "Excluir conta" abre o diálogo de confirmação', (tester) async {
    await tester.pumpWidget(montar(
      SettingsPage(
        onDeleteAccount: () async {},
        howItWorksPageBuilder: (_) => const SizedBox(),
      ),
    ));

    await tester.tap(find.text('Excluir conta'));
    await tester.pumpAndSettle();

    // O diálogo pede a palavra-chave digitada — se ele abriu, este texto existe.
    expect(find.textContaining('EXCLUIR para confirmar'), findsOneWidget);
  });

  testWidgets('mostrarDialogoLogout abre o diálogo', (tester) async {
    await tester.pumpWidget(montar(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => mostrarDialogoLogout(context),
              child: const Text('sair'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('sair'));
    await tester.pumpAndSettle();

    expect(find.text('Deseja realmente sair?'), findsOneWidget);
  });
}
