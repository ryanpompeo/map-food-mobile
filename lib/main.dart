import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
      // 390x844 tamanho padrao de celular
      designSize: const Size(390, 844),

      // Faz com que os textos também se adaptem ao tamanho da tela
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(textTheme: GoogleFonts.plusJakartaSansTextTheme()),
          debugShowCheckedModeBanner: false,
          // usado para aplicar responsividade no app inteiro
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 800, name: TABLET),
            ],
          ),
          initialRoute: '/tipoConta',
          routes: {
            '/tipoConta': (context) => const TipoConta(),
            '/semLogin': (context) => const PageSemLogin(),
          },
        );
      },
    );
  }
}
