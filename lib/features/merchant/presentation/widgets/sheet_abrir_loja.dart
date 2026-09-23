import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_choice_chip.dart';
import 'package:map_food/features/merchant/presentation/controllers/modo_ronda.dart';

class AberturaEscolhida {
  final ModoRonda modo;
  final DateTime? encerraEm;

  const AberturaEscolhida(this.modo, {this.encerraEm});
}

const List<Duration> duracoesSugeridas = [
  Duration(hours: 2),
  Duration(hours: 4),
  Duration(hours: 6),
];

const Duration duracaoPadrao = Duration(hours: 4);

Future<AberturaEscolhida?> mostrarSheetAbrirLoja(
  BuildContext context, {
  DateTime Function()? agora,
  Duration maximo = const Duration(hours: 12),
}) {
  return showModalBottomSheet<AberturaEscolhida>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => SheetAbrirLoja(agora: agora ?? DateTime.now, maximo: maximo),
  );
}

class SheetAbrirLoja extends StatefulWidget {
  final DateTime Function() agora;

  final Duration maximo;

  const SheetAbrirLoja({
    super.key,
    required this.agora,
    this.maximo = const Duration(hours: 12),
  });

  @override
  State<SheetAbrirLoja> createState() => _SheetAbrirLojaState();
}

class _SheetAbrirLojaState extends State<SheetAbrirLoja> {
  ModoRonda _modo = ModoRonda.parado;
  Duration _duracao = duracaoPadrao;
  DateTime? _horarioEscolhido;

  DateTime get _encerraEm => _horarioEscolhido ?? widget.agora().add(_duracao);

  String get _rotuloDoFim {
    final fim = _encerraEm;
    final hora = fim.hour.toString().padLeft(2, '0');
    final minuto = fim.minute.toString().padLeft(2, '0');
    final agora = widget.agora();
    final virouODia = fim.day != agora.day || fim.month != agora.month;
    return virouODia ? '$hora:$minuto de amanhã' : '$hora:$minuto';
  }

  Future<void> _escolherHorario() async {
    final agora = widget.agora();
    final escolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(agora.add(_duracao)),
      helpText: 'Fechar a loja às',
    );
    if (escolhido == null || !mounted) return;
    var fim = DateTime(agora.year, agora.month, agora.day, escolhido.hour, escolhido.minute);
    if (!fim.isAfter(agora)) fim = fim.add(const Duration(days: 1));
    final teto = agora.add(widget.maximo);
    setState(() => _horarioEscolhido = fim.isAfter(teto) ? teto : fim);
  }

  void _usarSugestao(Duration duracao) => setState(() {
        _duracao = duracao;
        _horarioEscolhido = null;
      });

  void _confirmar() {
    final parado = _modo == ModoRonda.parado;
    Navigator.of(context).pop(
      AberturaEscolhida(_modo, encerraEm: parado ? _encerraEm : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final parado = _modo == ModoRonda.parado;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Como você vai aparecer?', style: AppText.h2(context)),
            const SizedBox(height: Spacing.xs),
            Text(
              'Isso muda o que os clientes veem e quanta bateria o app gasta.',
              style: AppText.secondary(context).copyWith(height: 1.4),
            ),
            const SizedBox(height: Spacing.lg),
            _OpcaoDeModo(
              titulo: 'Estou parado aqui',
              descricao: 'Salva este ponto e economiza bateria. Para quem fica no mesmo lugar.',
              icone: AppIcons.mapPin,
              selecionada: parado,
              onTap: () => setState(() => _modo = ModoRonda.parado),
            ),
            const SizedBox(height: Spacing.sm),
            _OpcaoDeModo(
              titulo: 'Estou em movimento',
              descricao: 'Seu ponto anda no mapa junto com você, e gasta mais bateria.',
              icone: AppIcons.navigationArrow,
              selecionada: !parado,
              onTap: () => setState(() => _modo = ModoRonda.emMovimento),
            ),
            if (parado) ...[
              const SizedBox(height: Spacing.lg),
              Text('Fecha sozinha às $_rotuloDoFim', style: AppText.title(context)),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  for (final duracao in duracoesSugeridas)
                    AppChoiceChip(
                      label: '${duracao.inHours} h',
                      selected: _horarioEscolhido == null && _duracao == duracao,
                      onTap: () => _usarSugestao(duracao),
                    ),
                  AppChoiceChip(
                    label: 'Escolher horário',
                    icon: AppIcons.clock,
                    selected: _horarioEscolhido != null,
                    onTap: _escolherHorario,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Você pode encerrar antes quando quiser.',
                style: AppText.caption(context).copyWith(color: colors.textSecondary),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            AppButton(
              label: 'Abrir loja',
              icon: AppIcons.storefront,
              onPressed: _confirmar,
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoDeModo extends StatelessWidget {
  final String titulo;

  final String descricao;

  final IconData icone;

  final bool selecionada;

  final VoidCallback onTap;

  const _OpcaoDeModo({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Semantics(
      button: true,
      selected: selecionada,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.lg),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: selecionada ? colors.surfaceAlt : colors.surface,
            borderRadius: BorderRadius.circular(Radii.lg),
            border: Border.all(
              color: selecionada ? colors.brandContent : colors.border,
              width: selecionada ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icone,
                size: AppIconSize.md,
                color: selecionada ? colors.brandContent : colors.textSecondary,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: AppText.title(context)),
                    const SizedBox(height: 2),
                    Text(
                      descricao,
                      style: AppText.caption(context).copyWith(
                        color: colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selecionada)
                Icon(AppIcons.checkCircle, size: AppIconSize.md, color: colors.brandContent),
            ],
          ),
        ),
      ),
    );
  }
}
