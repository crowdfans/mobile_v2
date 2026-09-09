import 'package:flutter/material.dart';

/// Pill dourado "Jams" do Meu Perfil (print Superfã).
class MeJamsPill extends StatelessWidget {
  const MeJamsPill({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5C451),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: const Key('profile-jams'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/jam-coin.png',
                width: 18,
                height: 18,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.monetization_on,
                  size: 18,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Jams',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
