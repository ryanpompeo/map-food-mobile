import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_food/pages/logins/page_cadastro_conta_comercial.dart';
import 'package:map_food/pages/logins/page_cadastro_usuario.dart';
import 'package:map_food/pages/page_sem_login.dart';
import 'package:map_food/pages/tipo_conta.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,

      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),

          builder: (context, child) {
            final media = MediaQuery.of(context);

            /// limita o crescimento da fonte do sistema
            final limitedMedia = media.copyWith(
              textScaleFactor: media.textScaleFactor.clamp(0.9, 1.5),
            );

            return MediaQuery(
              data: limitedMedia,
              child: ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: const [
                  Breakpoint(start: 0, end: 450, name: MOBILE),
                  Breakpoint(start: 451, end: 800, name: TABLET),
                ],
              ),
            );
          },

          initialRoute: '/tipoConta',

          routes: {
            '/tipoConta': (context) => const TipoConta(),
            '/semLogin': (context) => const PageSemLogin(),
            '/cadastroUsuario': (context) => const PageCadastroUsuario(),
            '/cadastroContaComercial': (context) =>
                const PageCadastroContaComercial(),
          },
        );
      },
    );
  }
}
