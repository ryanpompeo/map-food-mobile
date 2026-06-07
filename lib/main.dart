import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_food/app/router/app_routes.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/models/consumer/consumer_register_request.dart';
import 'package:map_food/models/store/store_create_request.dart';
import 'package:map_food/pages/auth/pages/login_page.dart';
import 'package:map_food/pages/auth/pages/merchant_register_page.dart';
import 'package:map_food/pages/auth/pages/consumer_register_page.dart';
import 'package:map_food/pages/consumer/consumer_home_page.dart';
import 'package:map_food/pages/guest/guest_home_page.dart';
import 'package:map_food/pages/auth/pages/account_type_page.dart';
import 'package:map_food/pages/guest/profile/how_it_works_page.dart';
import 'package:map_food/pages/merchant/merchant_home_page.dart';
import 'package:map_food/pages/merchant/working_page.dart';
import 'package:map_food/pages/merchant/store_register_page.dart';

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

          initialRoute: '/homeMerchant',

          routes: {
            AppRoutes.root: (context) => const GuestHomePage(),
            '/login': (context) => const LoginPage(),
            '/howItWorks': (context) => const HowItWorksPage(),
            '/accountType': (context) => const AccountTypePage(),
            '/consumerRegister': (context) => const ConsumerRegisterPage(),
            '/merchantRegister': (context) => const MerchantRegisterPage(),
            '/storeRegister': (context) => const StoreRegisterPage(),
            '/homeMerchant': (context) => const MerchantHomePage(
              requestData: StoreCreateRequest(
                nome: 'Teste',
                statusLoja: 'ATIVO',
                categoriaIds: [1, 2, 3],
              ),

              fotoDestaqueId: 0,
              fotosGaleriaIds: [],
            ),

            '/consumerHome': (context) => const ConsumerHomePage(
              requestData: ConsumerRegisterRequest(
                nome: 'Nome Teste',
                email: 'email@email.com',
                cpf: '12345678910',
                celular: '19498489',
                senha: 'senha1234',
              ),
            ),
          },
        );
      },
      //76aje
    );
  }
}
