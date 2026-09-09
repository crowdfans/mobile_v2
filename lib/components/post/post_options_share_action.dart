import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Ação compacta de share no sheet dos 3 pontinhos.
class PostOptionsShareAction extends StatelessWidget {
  const PostOptionsShareAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: iconColor ?? colors.primary, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
