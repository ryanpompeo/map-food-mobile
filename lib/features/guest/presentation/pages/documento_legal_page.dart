import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class DocumentoLegalPage extends StatelessWidget {
  final String titulo;
  final String markdown;

  const DocumentoLegalPage({
    super.key,
    required this.titulo,
    required this.markdown,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      appBar: AppBar(
        backgroundColor: context.mapColors.mainBackground,
        foregroundColor: context.mapColors.primaryText,
        surfaceTintColor: context.mapColors.mainBackground,
        elevation: 0,
        centerTitle: true,
        title: Text(
          titulo,
          style: AppText.subtitulo(context).copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            AppIcons.caretLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
          ),
        ),
      ),
      body: SafeArea(
        child: Markdown(
          padding: EdgeInsets.all(AppSpacing.lg),
          data: markdown,
          physics: const BouncingScrollPhysics(),
          styleSheet: MarkdownStyleSheet(
            h1: AppText.titulo(context).copyWith(fontSize: 22, fontWeight: FontWeight.w900),
            h2: AppText.subtitulo(context).copyWith(
              fontSize: 18,
              color: ColorsPalette.redComponents,
              fontWeight: FontWeight.bold,
            ),
            p: AppText.corpo(context).copyWith(height: 1.5),
            strong: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.mapColors.primaryText,
            ),
            listBullet: const TextStyle(color: ColorsPalette.redComponents),
          ),
        ),
      ),
    );
  }
}
