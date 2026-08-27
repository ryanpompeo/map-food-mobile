import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/session/session_manager.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/onboarding_storage.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';
import 'package:map_food/core/ui/theme/theme_controller.dart';
import 'package:map_food/features/auth/presentation/pages/login_page.dart';
import 'package:map_food/features/auth/presentation/pages/merchant_register_page.dart';
import 'package:map_food/features/auth/presentation/pages/consumer_register_page.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_home_page.dart';
import 'package:map_food/features/guest/presentation/pages/guest_home_page.dart';
import 'package:map_food/features/auth/presentation/pages/account_type_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';
import 'package:map_food/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aguarda a preferência de tema salva ANTES do runApp — sem isso, o
  // primeiro frame nasceria sempre no ThemeMode.system e só trocaria pro
  // tema salvo um frame depois, gerando um flash de tema errado (FOUC).
  final themeController = await ThemeController.load();

  // Hidrata a sessão em memória antes do primeiro frame: a partir daqui,
  // qualquer tela lê papel/id/nome de forma síncrona via SessionStore, sem
  // repetir I/O em SharedPreferences.
  await SessionStore.instance.hydrate();
  final session = SessionStore.instance.value;

  String initialRoute;
  if (session != null) {
    // Sessão salva sempre ganha do onboarding: quem já está logado nunca
    // deve ver a tela de boas-vindas de novo (nem depois de atualizar o app).
    initialRoute = session.tipo == 'COMERCIANTE'
        ? AppRoutes.merchantDashboard
        : AppRoutes.consumerHome;
  } else if (!await OnboardingStorage.jaVisto()) {
    initialRoute = AppRoutes.onboarding;
  } else {
    initialRoute = AppRoutes.root;
  }

  runApp(MyApp(initialRoute: initialRoute, themeController: themeController));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final ThemeController themeController;

  const MyApp({super.key, required this.initialRoute, required this.themeController});

  @override
  Widget build(BuildContext context) {
    // Isolamento de rebuild: só as props de tema do MaterialApp (theme/
    // darkTheme/themeMode) ficam dentro do builder. Trocar o tema não passa
    // por setState na raiz nem reconstrói a árvore de rotas já montada — o
    // MaterialApp só recebe novos valores de tema, e o Flutter reaproveita
    // (via reconciliação de Element) tudo o que está abaixo dele.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          navigatorKey: SessionManager.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'MapFood',
          themeMode: mode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // Escala de texto do app: acompanha o sistema até 2×, que é o teto
          // do Android.
          //
          // Era 1,5× — um curativo sobre um layout que tinha ~30 alturas
          // cravadas e cortaria o texto acima disso. Subiu para 2× depois que
          // essas amarras viraram `minHeight`, os ícones que acompanham texto
          // passaram a escalar junto e as faixas que genuinamente não podem
          // crescer ganharam teto **local** via `MaxTextScale`
          // (`core/ui/utils/text_scale.dart`).
          //
          // O teto que sobra aqui não é mais um curativo: acima de 2× o
          // conteúdo continua legível, mas telas densas (o detalhe da loja, o
          // dashboard do comerciante) passam a exigir rolagem longa demais
          // para o que mostram. Se for para subir de novo, é caso a caso e com
          // um caso novo em `test/dynamic_type_test.dart` para cada tela.
          //
          // `minScaleFactor: 0.9` continua: ninguém precisa de fonte menor por
          // acessibilidade, e abaixo disso os rótulos de 10-11px do app ficam
          // ilegíveis mesmo para quem escolheu reduzir.
          builder: (context, widget) {
            final media = MediaQuery.of(context);

            final limitedMedia = media.copyWith(
              textScaler: media.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 2.0,
              ),
            );

            return MediaQuery(data: limitedMedia, child: widget!);
          },

          initialRoute: initialRoute,

          routes: {
            AppRoutes.root: (context) => const GuestHomePage(),
            AppRoutes.onboarding: (context) => const OnboardingPage(),
            AppRoutes.login: (context) => const LoginPage(),
            AppRoutes.howItWorks: (context) => const HowItWorksPage(),
            AppRoutes.accountType: (context) => const AccountTypePage(),
            AppRoutes.consumerRegister: (context) => const ConsumerRegisterPage(),
            AppRoutes.merchantRegister: (context) => const MerchantRegisterPage(),
            AppRoutes.storeRegister: (context) => const StoreRegisterPage(),
            AppRoutes.merchantDashboard: (context) => const MerchantHomePage(),
            AppRoutes.consumerHome: (context) => const ConsumerHomePage(),
          },
        );
      },
    );
  }
}
