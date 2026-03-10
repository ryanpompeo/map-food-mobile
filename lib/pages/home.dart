import 'package:flutter/material.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/page_sem_login.dart';
import 'package:map_food/pages/tipo_conta.dart';

class HomeFinal extends StatefulWidget {
  const HomeFinal({super.key});

  @override
  State<HomeFinal> createState() => _HomeFinalState();
}

class _HomeFinalState extends State<HomeFinal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.brancoBackground,
      body: SafeArea(child: TipoConta()),
    );
  }
}
