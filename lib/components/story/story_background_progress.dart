import 'package:crowdfans/constants/story_background_videos.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Barras de progresso no topo do onboarding (espelho do `StoreBackgroundProgress`).
class StoryBackgroundProgress extends StatelessWidget {
  const StoryBackgroundProgress({
    super.key,
    required this.currentIndex,
    required this.isSecondStory,
    required this.progress,
    required this.top,
  });

  final int currentIndex;
  final bool isSecondStory;
  final double progress;
  final double top;

  @override
  Widget build(BuildContext context) {
    final track = isSecondStory
        ? const Color(0x330A0A0A)
        : const Color(0x47FFFFFF);
    final fill = isSecondStory ? AppPalette.platinum950 : AppPalette.platinum50;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Row(
          children: [
            for (var i = 0; i < storyBackgroundVideos.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: i < currentIndex
                          ? 1
                          : i == currentIndex
                          ? progress.clamp(0, 1)
                          : 0,
                      backgroundColor: track,
                      color: fill,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
