import 'package:flutter/material.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/session/session_manager.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/storage/onboarding_storage.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
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

  final themeController = await ThemeController.load();

  await SessionStore.instance.hydrate();
  final session = SessionStore.instance.value;

  String initialRoute;
  if (session != null) {
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

  static final Map<String, WidgetBuilder> _rotas = {
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
  };

  @override
  Widget build(BuildContext context) {
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

          onGenerateInitialRoutes: (rota) => [
            appPageRoute(
              builder: (context) => (_rotas[rota] ?? _rotas[AppRoutes.root]!)(context),
              settings: RouteSettings(name: rota),
            ),
          ],

          routes: _rotas,
        );
      },
    );
  }
}
