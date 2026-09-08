import 'dart:async';

import 'package:crowdfans/components/onboarding/onboarding_buttons.dart';
import 'package:crowdfans/components/onboarding/presentation_slide.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      setState(() => _index = (_index + 1) % presentationSlides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  PresentationSlide(
                    data: presentationSlides[_index],
                    textColor: textColor,
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
