import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/charts/chart_data.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';

class DistributionDonutChart extends StatefulWidget {
  final List<DonutSlice> slices;

  final Widget? centro;

  const DistributionDonutChart({super.key, required this.slices, this.centro});

  @override
  State<DistributionDonutChart> createState() => _DistributionDonutChartState();
}

class _DistributionDonutChartState extends State<DistributionDonutChart> {
  int _tocada = -1;

  static const double _lado = 132.0;
  static const double _raio = 26.0;
  static const double _raioTocado = 32.0;

  double get _total => widget.slices.fold(0.0, (soma, s) => soma + s.value);

  @override
  Widget build(BuildContext context) {
    if (widget.slices.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _lado,
          height: _lado,
          child: RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2.0,
                    centerSpaceRadius: 34.0,
                    startDegreeOffset: -90.0,
                    pieTouchData: PieTouchData(
                      touchCallback: (evento, resposta) {
                        final indice = evento.isInterestedForInteractions
                            ? (resposta?.touchedSection?.touchedSectionIndex ?? -1)
                            : -1;
                        if (indice != _tocada) setState(() => _tocada = indice);
                      },
                    ),
                    sections: [
                      for (var i = 0; i < widget.slices.length; i++)
                        PieChartSectionData(
                          value: widget.slices[i].value,
                          color: widget.slices[i].color,
                          radius: i == _tocada ? _raioTocado : _raio,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                if (widget.centro != null) widget.centro!,
              ],
            ),
          ),
        ),
        const SizedBox(width: Spacing.base),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.slices.length; i++) ...[
                if (i > 0) const SizedBox(height: 8.0),
                _ItemLegenda(
                  slice: widget.slices[i],
                  percentual: _total == 0 ? 0 : (widget.slices[i].value / _total) * 100,
                  destacado: i == _tocada,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  final DonutSlice slice;
  final double percentual;
  final bool destacado;

  const _ItemLegenda({
    required this.slice,
    required this.percentual,
    required this.destacado,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Row(
      children: [
        Container(
          width: 10.0,
          height: 10.0,
          decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            slice.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.caption(context).copyWith(
              color: destacado ? colors.textPrimary : colors.textSecondary,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Text(
          '${percentual.round()}%',
          style: AppText.numeric(context, size: 12).copyWith(
            fontWeight: FontWeight.w700,
            color: destacado ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
