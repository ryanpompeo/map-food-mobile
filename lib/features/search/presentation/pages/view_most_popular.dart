import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

class ViewMostPopular extends StatefulWidget {
  const ViewMostPopular({super.key});

  @override
  State<ViewMostPopular> createState() => _ViewMostPopularState();
}

class _ViewMostPopularState extends State<ViewMostPopular> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Em desenvolvimento"),
              Text('Área para as lojas mais populares do momento'),
            ],
          ),
        ),
      ),
    );
    
  }
}
