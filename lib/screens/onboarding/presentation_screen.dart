import 'package:crowdfans/components/onboarding/onboarding_buttons.dart';
import 'package:crowdfans/components/onboarding/presentation_slide.dart';
import 'package:crowdfans/components/story/story_background.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Onboarding inicial com stories em vídeo (igual ao Expo).
class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  int _index = 0;

  void handleVideoChange(int index) {
    setState(() => _index = index);
  }

  void handleSuperfan() {
    context.push(Pages.loginFan);
  }

  void handleArtist() {
    context.push(Pages.loginArtist);
  }

  @override
  Widget build(BuildContext context) {
    final darkText = _index == 1;
    final textColor = darkText ? AppPalette.platinum950 : AppPalette.platinum50;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          StoryBackground(onVideoChange: handleVideoChange),
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
                    onSuperfan: handleSuperfan,
                    onArtist: handleArtist,
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
