import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

class ConsumerReviewPage extends StatefulWidget {
  const ConsumerReviewPage({super.key});

  @override
  State<ConsumerReviewPage> createState() => _ConsumerReviewPageState();
}

class _ConsumerReviewPageState extends State<ConsumerReviewPage> {
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
          "Minhas Avaliações",
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(LucideIcons.star, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "Em breve",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A listagem das avaliações que você fez ainda não está '
                  'disponível nesta versão do app.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
