import 'package:flutter/material.dart';

/// Banner promocional de recarga com arte oficial (CF-168).
class WalletPromoBanner extends StatelessWidget {
  const WalletPromoBanner({
    super.key,
    required this.countdown,
    required this.onRecharge,
  });

  final String countdown;
  final VoidCallback onRecharge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRecharge,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 7,
                child: Image.asset(
                  'assets/images/Banner Jam Coins.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF7E49FF),
                    alignment: Alignment.center,
                    child: const Text(
                      '15% OFF na recarga',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 12,
                child: Text(
                  'Oferta termina em $countdown',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
