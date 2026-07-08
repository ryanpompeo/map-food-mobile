import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/auth/presentation/pages/login_page.dart';
import 'package:map_food/features/auth/presentation/pages/merchant_register_page.dart';
import 'package:map_food/features/auth/presentation/pages/consumer_register_page.dart';
import 'package:map_food/features/consumer/presentation/pages/consumer_home_page.dart';
import 'package:map_food/features/guest/presentation/pages/guest_home_page.dart';
import 'package:map_food/features/auth/presentation/pages/account_type_page.dart';
import 'package:map_food/features/guest/presentation/pages/how_it_works_page.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';
import 'package:map_food/features/store/presentation/pages/store_register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = await AuthStorage.getSession();

  String initialRoute;
  if (session != null) {
    initialRoute = session.tipo == 'COMERCIANTE'
        ? AppRoutes.merchantDashboard
        : AppRoutes.consumerHome;
  } else {
    initialRoute = AppRoutes.root;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MapFood',
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(),
            scaffoldBackgroundColor: ColorsPalette.whiteBackground,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: ColorsPalette.black,
              selectionColor: ColorsPalette.black.withValues(alpha: 0.15),
              selectionHandleColor: ColorsPalette.black,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          builder: (context, widget) {
            final media = MediaQuery.of(context);
            final limitedMedia = media.copyWith(
              textScaler: media.textScaler.clamp(
                minScaleFactor: 0.9,
                maxScaleFactor: 1.11,
              ),
            );

            return MediaQuery(data: limitedMedia, child: widget!);
          },

          initialRoute: '/',

          routes: {
            AppRoutes.root: (context) => const GuestHomePage(),
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
