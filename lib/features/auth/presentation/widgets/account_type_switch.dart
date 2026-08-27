import 'package:flutter/material.dart';
import 'package:map_food/core/ui/widgets/semantic_tap_area.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

/// Seletor "Consumidor / Comerciante" do login.
///
/// A cor do segmento ativo carrega significado e é a mesma em toda a jornada
/// de cada papel: **preto** para consumidor (o CTA neutro do app) e
/// **vermelho** para comerciante. É o que faz o botão "Entrar" logo abaixo
/// mudar de cor junto — a pessoa vê para qual conta está entrando sem ler.
///
/// Trilho com raio 12 (não pílula): o campo de e-mail logo abaixo tem a mesma
/// forma, e os dois elementos passam a ler como um bloco só.
class AccountTypeSwitch extends StatelessWidget {
  /// 'CONSUMIDOR' ou 'COMERCIANTE'.
  final String value;
  final ValueChanged<String> onChanged;

  const AccountTypeSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.mapColors.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.md + 4),
      ),
      child: Row(
        children: [
          // Consumidor usa o neutro forte do tema (que inverte no escuro);
          // comerciante usa o vermelho de marca, que vale nos dois temas.
          _segmento(
            context,
            tipo: 'CONSUMIDOR',
            label: 'Consumidor',
            ativo: context.mapColors.selectedSurface,
            aoAtivo: context.mapColors.onSelectedSurface,
          ),
          const SizedBox(width: 4),
          _segmento(
            context,
            tipo: 'COMERCIANTE',
            label: 'Comerciante',
            ativo: MfColor.brand,
            aoAtivo: ColorsPalette.white,
          ),
        ],
      ),
    );
  }

  Widget _segmento(
    BuildContext context, {
    required String tipo,
    required String label,
    required Color ativo,
    required Color aoAtivo,
  }) {
    final selecionado = value == tipo;

    return Expanded(
      // Segmentado, mesma leitura do seletor de tema: o ativo ganha uma
      // superfície que o outro não tem, então o estado não depende só de cor.
      child: SemanticTapArea(
        label: label,
        selected: selecionado,
        onTap: () => onChanged(tipo),
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Curves.easeOutCubic,
          // Mesmo tratamento do seletor de tema: altura mínima.
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selecionado ? ativo : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Text(
            label,
            style: AppText.button(context).copyWith(
              fontSize: 14,
              color: selecionado ? aoAtivo : context.mapColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
