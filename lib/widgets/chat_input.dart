import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final void Function() onSend;

  // Controla o foco do campo de texto (abrir/fechar teclado)
  final FocusNode focusNode;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0, top: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: ColorsPalette.branco,
          ),

          child: Row(
            children: [
              Icon(
                LucideIcons.search,
                color: ColorsPalette.vermelhoVivido,
                size: 22,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: TextField(
                  controller: controller,
                  // Desativa correções automáticas
                  autocorrect: false,
                  enableSuggestions: false,
                  spellCheckConfiguration: SpellCheckConfiguration.disabled(),
                  style: TextStyle(color: Colors.black.withOpacity(0.82)),
                  cursorColor: ColorsPalette.vermelhoVivido,
                  cursorWidth: 2,

                  decoration: InputDecoration(
                    // Remove padding interno padrão do TextField
                    // evita desalinhamento vertical
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: "Buscar...",
                    hintStyle: TextStyle(
                      color: ColorsPalette.cinzaComponents.withOpacity(0.75),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              GestureDetector(
                onTap: onSend,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorsPalette.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.chevronRight,
                    color: ColorsPalette.vermelhoVivido,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
