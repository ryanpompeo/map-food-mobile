import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Campo de formulário do app.
///
/// O que mudou na v2 (a API é a mesma — são 27 call sites):
///
/// - **Raio 12 no lugar da pílula.** Campo em cápsula é a forma de um chip,
///   não de uma área de digitação: o texto encosta nas laterais curvas e a
///   linha de leitura fica torta. Quem define a forma agora é o
///   `inputDecorationTheme`, não este widget.
/// - **Superfície rebaixada** (`surfaceAlt`) em vez de `surface`. Um campo é
///   um buraco no papel, não um objeto sobre ele — antes o fundo do campo era
///   idêntico ao do card que o continha, e só a borda o separava.
/// - **Nada de `filled`/`fillColor`/`hintStyle` locais.** Estavam
///   sobrescrevendo o tema, então mudar o tema não mudava os formulários.
/// - **Rótulo em `caption`**, com peso 600 e no tom secundário: o rótulo
///   orienta, o valor digitado é que deve ter contraste alto.
class AppFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;

  /// Ícone à esquerda. Mantenha só onde ele informa de verdade (busca, senha,
  /// telefone) — em todo campo, vira ruído e come largura útil.
  final bool showIcon;

  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// Foco deste campo — necessário para encadear a navegação do teclado
  /// (ver [onSubmitted]).
  final FocusNode? focusNode;

  /// Tecla de ação do teclado. Use `TextInputAction.next` em todo campo
  /// menos o último do formulário, que recebe `done`: sem isso o teclado
  /// mostra "concluído" em todos e fecha a cada campo, obrigando o usuário
  /// a tocar de novo na tela para continuar.
  final TextInputAction? textInputAction;

  /// Disparado ao confirmar no teclado. Combine com [focusNode] do próximo
  /// campo (`FocusScope.of(context).requestFocus(proximo)`) ou com o submit
  /// do formulário, no último campo.
  final ValueChanged<String>? onSubmitted;

  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.showIcon = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    final effectivePrefixIcon = prefixIcon ??
        (showIcon && icon != null
            ? Icon(icon, color: colors.textTertiary, size: AppIconSize.md)
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Text(
            label,
            style: AppText.caption(context).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        // O rótulo visual acima já é lido em sequência pela maioria dos
        // leitores de tela, mas não é associado ao campo de forma formal —
        // o Semantics abaixo garante essa associação (WCAG 4.1.2), sem
        // duplicar nada pra quem não usa leitor de tela (o Text visual
        // continua sendo a única coisa renderizada na tela).
        Semantics(
          label: label,
          textField: true,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            validator: validator,
            inputFormatters: inputFormatters,
            maxLines: obscureText ? 1 : maxLines,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            textAlignVertical: maxLines > 1 ? TextAlignVertical.top : TextAlignVertical.center,
            // Valor digitado com contraste alto e peso 500: é o conteúdo
            // real do campo, precisa ganhar do rótulo e do placeholder.
            style: AppText.body(context).copyWith(
              fontWeight: FontWeight.w500,
              color: enabled ? colors.textPrimary : colors.textTertiary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: effectivePrefixIcon,
              suffixIcon: suffixIcon,
              // Some com o "0/1000" que o Flutter injeta sozinho quando há
              // maxLength — quando fizer falta, o call site liga de volta.
              counterText: '',
              // Ícone mais próximo do texto: o padrão do Material reserva
              // 48px de caixa e abre um vão grande entre ícone e conteúdo.
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 24),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: maxLines > 1 ? Spacing.base : 15.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
