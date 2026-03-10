import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/tipo_conta.dart';
import 'package:map_food/widgets/chat_input.dart';

class PageSemLogin extends StatefulWidget {
  const PageSemLogin({super.key});

  @override
  State<PageSemLogin> createState() => _PageSemLogin();
}

class _PageSemLogin extends State<PageSemLogin> {
  final TextEditingController controller = TextEditingController();
  final FocusNode chatFocus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    chatFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
