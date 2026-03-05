import 'package:flutter/material.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/map_teste.dart';
import 'package:map_food/pages/page_sem_login.dart';

class HomeFinal extends StatefulWidget {
  const HomeFinal({super.key});

  @override
  State<HomeFinal> createState() => _HomeFinalState();
}

class _HomeFinalState extends State<HomeFinal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.brancoOff,
      body: const SafeArea(child: MapTeste()),
    );
  }
}
