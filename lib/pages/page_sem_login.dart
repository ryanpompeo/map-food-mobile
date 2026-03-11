import 'package:flutter/material.dart';

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
