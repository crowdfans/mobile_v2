import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Linha de rede social na seção Outras redes do Sobre.
class ArtistProfileSocialLinkRow extends StatelessWidget {
  const ArtistProfileSocialLinkRow({
    super.key,
    required this.label,
    required this.handle,
    required this.asset,
    this.onPressed,
  });

  final String label;
  final String handle;
  final String asset;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final enabled = onPressed != null && handle.trim().isNotEmpty;
    return Semantics(
      button: enabled,
      label: enabled ? '$label $handle' : '$label não vinculada',
      child: InkWell(
        onTap: enabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                asset,
                width: 22,
                height: 22,
                errorBuilder: (_, _, _) => Icon(
                  Icons.link,
                  size: 22,
                  color: colors.icon,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handle.trim().isEmpty ? 'Não vinculada' : handle.trim(),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (enabled)
                Icon(Icons.open_in_new_rounded, size: 18, color: colors.icon),
            ],
          ),
        ),
      ),
    );
  }
}
