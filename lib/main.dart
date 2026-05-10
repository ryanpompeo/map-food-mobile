import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/auth/pages/login_page.dart';
import 'package:map_food/pages/auth/pages/merchant_register_page.dart';
import 'package:map_food/pages/auth/pages/consumer_register_page.dart';
import 'package:map_food/pages/host/guest_home_page.dart';
import 'package:map_food/pages/auth/pages/account_type_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
              selectionColor: ColorsPalette.black.withOpacity(0.15),
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
                maxScaleFactor: 1.15,
              ),
            );

            return MediaQuery(data: limitedMedia, child: widget!);
          },

          initialRoute: '/',
          routes: {
            '/': (context) => const GuestHomePage(),
            '/login': (context) => const LoginPage(),
            '/accountType': (context) => const AccountTypePage(),
            '/consumerRegister': (context) => const ConsumerRegisterPage(),
            '/merchantRegister': (context) => const MerchantRegisterPage(),
          },
        );
      },
    );
  }
}
