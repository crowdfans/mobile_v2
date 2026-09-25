import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// CTA do cover do perfil público: Seguir / Membership ♪ / Membership ✓ (CF-185).
enum ArtistProfileCoverCtaKind { follow, membershipSubscribe, membershipActive }

class ArtistProfileCoverCta extends StatelessWidget {
  const ArtistProfileCoverCta({
    super.key,
    required this.kind,
    required this.busy,
    required this.onPressed,
  });

  final ArtistProfileCoverCtaKind kind;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return _pill(
        background: Colors.white.withValues(alpha: 0.85),
        child: const Text(
          'Aguarde...',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
      );
    }

    return switch (kind) {
      ArtistProfileCoverCtaKind.follow => _pill(
        background: Colors.white,
        onPressed: onPressed,
        child: const Text(
          '+ Seguir',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ),
      ArtistProfileCoverCtaKind.membershipSubscribe => _pill(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFB45309), Color(0xFF1C1C1E)],
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Membership',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF5C451),
              ),
            ),
            const SizedBox(width: 6),
            SvgPicture.asset(
              'assets/icons/Media & devices/music-note-01.svg',
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Color(0xFFF5C451),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
      ArtistProfileCoverCtaKind.membershipActive => _pill(
        background: Colors.white,
        onPressed: onPressed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Membership',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.check, size: 18, color: Color(0xFF1C1C1E)),
          ],
        ),
      ),
    };
  }

  Widget _pill({
    Color? background,
    Gradient? gradient,
    VoidCallback? onPressed,
    required Widget child,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(child: child),
    );
    if (gradient != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: content,
          ),
        ),
      );
    }
    return Material(
      color: background ?? Colors.white,
      shape: shape,
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: content,
      ),
    );
  }
}

/// Resolve o estado do CTA a partir de follow + assinatura (prints CF-185).
ArtistProfileCoverCtaKind artistProfileCoverCtaKind({
  required bool following,
  required bool subscribed,
}) {
  if (subscribed) {
    return ArtistProfileCoverCtaKind.membershipActive;
  }
  if (following) {
    return ArtistProfileCoverCtaKind.membershipSubscribe;
  }
  return ArtistProfileCoverCtaKind.follow;
}
