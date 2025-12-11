import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final void Function() onSend;

  const ChatInput({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColorsPalette.cinzaBg.withOpacity(0.90),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.atom,
                  color: ColorsPalette.branco.withOpacity(0.98),
                  size: 25,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: controller,

                    // MATA underline de vez
                    autocorrect: false,
                    enableSuggestions: false,
                    spellCheckConfiguration:
                        const SpellCheckConfiguration.disabled(),

                    style: const TextStyle(
                      color: ColorsPalette.brancoOff,
                      decoration: TextDecoration.none,
                    ),

                    cursorColor: ColorsPalette.branco,
                    cursorWidth: 2.5,
                    cursorOpacityAnimates: true,

                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,

                      hintText: "Tire suas dúvidas...",
                      hintStyle: TextStyle(
                        color: ColorsPalette.brancoOff.withOpacity(0.70),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    LucideIcons.chevronRight,
                    color: ColorsPalette.branco.withOpacity(0.90),
                  ),
                  onPressed: onSend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
