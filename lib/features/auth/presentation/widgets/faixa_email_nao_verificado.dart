import 'package:flutter/material.dart';
import 'package:map_food/core/session/session_store.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/auth/data/models/auth_response.dart';
import 'package:map_food/features/auth/presentation/widgets/aviso_email_nao_verificado.dart';

class FaixaEmailNaoVerificado extends StatelessWidget {
  const FaixaEmailNaoVerificado({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthResponse?>(
      valueListenable: SessionStore.instance,
      builder: (context, sessao, filho) {
        if (!SessionStore.instance.precisaVerificarEmail) return const SizedBox.shrink();
        return _Faixa(onConfirmar: () => abrirConfirmacaoDeEmail(context));
      },
    );
  }
}

class _Faixa extends StatelessWidget {
  final VoidCallback onConfirmar;

  const _Faixa({required this.onConfirmar});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onConfirmar,
          borderRadius: BorderRadius.circular(Radii.lg),
          child: Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Icon(AppIcons.envelope, size: AppIconSize.md, color: colors.brandContent),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Confirme seu e-mail', style: AppText.bodyStrong(context)),
                      const SizedBox(height: 2),
                      Text(
                        'Enquanto não confirmar, você não consegue avaliar nem denunciar lojas.',
                        style: AppText.caption(context).copyWith(
                          color: colors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(AppIcons.caretRight, size: AppIconSize.sm, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
