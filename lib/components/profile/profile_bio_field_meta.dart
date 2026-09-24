import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Contador + texto auxiliar sob o campo da bio.
class ProfileBioFieldMeta extends StatelessWidget {
  const ProfileBioFieldMeta({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Ela aparece no topo do seu perfil.',
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: colors.textTertiary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textTertiary,
          ),
        ),
      ],
    );
  }
}
