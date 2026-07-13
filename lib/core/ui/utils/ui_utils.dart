import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';

class UIUtils {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            'Erro',
            style: AppText.titulo(context).copyWith(fontWeight: FontWeight.bold, color: ColorsPalette.redComponents),
          ),
          content: Text(
            message,
            style: AppText.corpo(context).copyWith(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Entendi', style: AppText.botao(context).copyWith(color: Colors.black87)),
            ),
          ],
        );
      },
    );
  }
}
