import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';

class UIUtils {
  static void showErrorDialog(BuildContext context, String message) {
    AppToast.error(context, message);
  }
}
