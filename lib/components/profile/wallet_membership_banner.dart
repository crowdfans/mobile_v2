import 'package:flutter/material.dart';

/// CTA de membership na home de Jam Coins com arte oficial (CF-168).
class WalletMembershipBanner extends StatelessWidget {
  const WalletMembershipBanner({super.key, required this.onSubscribe});

  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSubscribe,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: Image.asset(
              'assets/images/Banner-Membership.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFF1F5F9),
                alignment: Alignment.center,
                child: const Text(
                  'Membership Fan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
