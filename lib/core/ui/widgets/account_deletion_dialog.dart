import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_theme.dart';

/// Dialog de alta fricção para exclusão de conta — ação destrutiva e
/// irreversível, então uma confirmação de toque único (Cancelar/Confirmar)
/// não é suficiente. Exige digitar "EXCLUIR" para habilitar o botão final.
class AccountDeletionDialog extends StatefulWidget {
  const AccountDeletionDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AccountDeletionDialog(),
    );
    return result ?? false;
  }

  @override
  State<AccountDeletionDialog> createState() => _AccountDeletionDialogState();
}

class _AccountDeletionDialogState extends State<AccountDeletionDialog> {
  static const _palavraConfirmacao = 'EXCLUIR';

  final _controller = TextEditingController();
  bool _confirmado = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final ok = _controller.text.trim().toUpperCase() == _palavraConfirmacao;
      if (ok != _confirmado) setState(() => _confirmado = ok);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      backgroundColor: colors.surface,
      title: Row(
        children: [
          Icon(LucideIcons.triangleAlert, color: colors.error, size: 22),
          const SizedBox(width: 8.0),
          Text('Excluir conta', style: TextStyle(color: colors.error, fontWeight: FontWeight.w900)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Essa ação é definitiva e não pode ser desfeita. Seu nome, foto, e-mail e telefone serão apagados. '
            'Avaliações e denúncias que você já fez continuam no histórico da plataforma, sem o seu nome.',
            style: TextStyle(color: colors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Digite EXCLUIR para confirmar:',
            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: _palavraConfirmacao,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: colors.error),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: _confirmado ? () => Navigator.pop(context, true) : null,
          child: Text(
            'Excluir definitivamente',
            style: TextStyle(
              color: _confirmado ? colors.error : colors.textSecondary.withValues(alpha: 0.4),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
