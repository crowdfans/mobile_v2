import 'package:crowdfans/components/badges/secret_mode_toggle_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Topo do composer: Cancelar | Novo post | secreto | Postar.
class NovoPostHeader extends StatelessWidget {
  const NovoPostHeader({
    super.key,
    required this.subtitle,
    required this.canSubmit,
    required this.publishing,
    required this.onCancel,
    required this.onPublish,
    this.showSecretToggle = false,
    this.isSecretMode = false,
    this.onToggleSecret,
  });

  final String subtitle;
  final bool canSubmit;
  final bool publishing;
  final VoidCallback onCancel;
  final VoidCallback onPublish;
  final bool showSecretToggle;
  final bool isSecretMode;
  final VoidCallback? onToggleSecret;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final publishEnabled = canSubmit && !publishing;
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('novo-post-cancel'),
                  onPressed: publishing ? null : onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Novo post',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showSecretToggle) ...[
                    SecretModeToggleButton(
                      active: isSecretMode,
                      onPressed: onToggleSecret,
                    ),
                    const SizedBox(width: 10),
                  ],
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: publishEnabled
                          ? colors.buttonPrimary
                          : colors.border,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        key: const Key('novo-post-submit'),
                        onTap: publishEnabled ? onPublish : null,
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: 84,
                          height: 36,
                          child: Center(
                            child: publishing
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.buttonPrimaryText,
                                    ),
                                  )
                                : Text(
                                    'Postar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: publishEnabled
                                          ? colors.buttonPrimaryText
                                          : colors.textTertiary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
