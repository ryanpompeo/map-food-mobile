import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';

class UIUtils {
  /// Mostra um erro como pop-up (ver [AppToast]) em vez de um dialog modal
  /// — mantido com esse nome para não precisar tocar em cada call site.
  static void showErrorDialog(BuildContext context, String message) {
    AppToast.error(context, message);
  }
}
