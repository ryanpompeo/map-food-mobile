import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/utils/text_scale.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';

enum EmptyStateTone {
  neutral,

  error,
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateTone tone;

  final Color? color;

  final bool dense;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.tone = EmptyStateTone.neutral,
    this.color,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final isError = tone == EmptyStateTone.error;

    final iconColor = color ?? (isError ? MfColor.danger : colors.textTertiary);
    final circleColor = isError
        ? MfColor.danger.withValues(alpha: 0.10)
        : colors.surfaceAlt;

    final circleSize = escalaIcone(context, dense ? 56.0 : 72.0);
    final iconSize = escalaIcone(context, dense ? 24.0 : 30.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: dense ? Spacing.lg : Spacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity),
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
          SizedBox(height: dense ? Spacing.base : Spacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.title(context),
          ),
          if (description != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              description!,
              textAlign: TextAlign.center,
              maxLines: fatorDeEscala(context) > 1.3 ? null : 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.secondary(context).copyWith(height: 1.5),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: dense ? Spacing.base : Spacing.lg),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              size: AppButtonSize.sm,
              expand: false,
              variant: isError ? AppButtonVariant.primary : AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}
