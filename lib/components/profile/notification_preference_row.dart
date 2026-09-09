import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Linha com switch de uma preferência de notificação.
class NotificationPreferenceRow extends StatelessWidget {
  const NotificationPreferenceRow({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.enabled,
    required this.showDivider,
    required this.onChanged,
  });

  final String title;
  final String description;
  final bool value;
  final bool enabled;
  final bool showDivider;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showDivider
              ? Border(top: BorderSide(color: colors.border))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeThumbColor: colors.surface,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
