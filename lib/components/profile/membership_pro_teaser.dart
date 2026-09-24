import 'package:flutter/material.dart';

/// Banner ilustrado Membership Fan (CF-167).
class MembershipProTeaser extends StatelessWidget {
  const MembershipProTeaser({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
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
