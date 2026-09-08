import 'dart:async';

import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/widgets/onboarding_buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _Slide {
  const _Slide({
    required this.title,
    required this.accent,
    required this.subtitle,
  });

  final String title;
  final String accent;
  final String subtitle;
}

const _slides = [
  _Slide(
    title: 'A música mudou.',
    accent: 'A forma de ser fã também',
    subtitle:
        'Aqui você pode interagir nos fã clubes oficiais, ver o que teu artista tá fazendo ou até mesmo interagir com ele.',
  ),
  _Slide(
    title: 'Ser fã é bom.',
    accent: 'Ser Superfã é outro nível.',
    subtitle:
        'Assina o Membership do seu artista favorito e mostra que você ama ele. Não tem jeito melhor de apoiar.',
  ),
  _Slide(
    title: 'Não precisa viralizar pra viver de música.',
    accent: 'Só precisa de fãs de verdade.',
    subtitle:
        'Aqui você constrói sua base de fãs fiéis e recebe apoio de quem realmente te ama e te escuta.',
  ),
];

/// Onboarding inicial (texto do Expo; vídeo de stories fica para o próximo corte).
class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _index = (_index + 1) % _slides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    final darkText = _index == 1;
    final textColor =
        darkText ? AppPalette.platinum950 : AppPalette.platinum50;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: darkText
                    ? const [Color(0xFFE8E0FF), AppPalette.purple400]
                    : const [AppPalette.platinum950, AppPalette.purple700],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 42, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CROWD FANS',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    slide.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    slide.accent,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide.subtitle,
                    style: TextStyle(color: textColor, fontSize: 18),
                  ),
                  const Spacer(),
                  OnboardingButtons(
                    darkMode: darkText,
                    onSuperfan: () => context.push(Pages.loginFan),
                    onArtist: () => context.push(Pages.loginArtist),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
