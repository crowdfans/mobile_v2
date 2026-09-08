import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

class LoginLabel extends StatelessWidget {
  const LoginLabel({super.key, required this.isArtist});

  final bool isArtist;

  @override
  Widget build(BuildContext context) {
    final accent = isArtist ? AuthAccentPalette.artist : AuthAccentPalette.fan;
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [accent.start, accent.end],
      ).createShader(bounds),
      child: const Text(
        'Login',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
