import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Aba Eu: avatar do perfil ou fallback SVG.
class BottomNavProfileTab extends StatelessWidget {
  const BottomNavProfileTab({
    super.key,
    required this.selected,
    required this.onTap,
    this.photoUrl,
  });

  final bool selected;
  final VoidCallback onTap;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final url = photoUrl?.trim();
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 3,
              color: selected ? colors.primary : Colors.transparent,
            ),
            const SizedBox(height: 12),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: colors.primary, width: 2)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: url != null && url.isNotEmpty
                  ? Image.network(url, fit: BoxFit.cover)
                  : SvgPicture.asset(
                      'assets/images/user-01.svg',
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
