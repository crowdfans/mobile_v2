import 'dart:async';

import 'package:crowdfans/components/story/story_background_progress.dart';
import 'package:crowdfans/constants/story_background_videos.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fallback se o mp4 não inicializar (mesmo intervalo do Expo).
const storyBackgroundFallbackDuration = Duration(seconds: 15);

/// Fundo em vídeo do onboarding: toca sozinho e avança ao terminar.
class StoryBackground extends StatefulWidget {
  const StoryBackground({super.key, this.onVideoChange});

  final ValueChanged<int>? onVideoChange;

  @override
  State<StoryBackground> createState() => _StoryBackgroundState();
}

class _StoryBackgroundState extends State<StoryBackground> {
  int _index = 0;
  int _generation = 0;
  VideoPlayerController? _controller;
  double _progress = 0;
  var _didAdvance = false;
  Timer? _fallback;

  @override
  void initState() {
    super.initState();
    handleOpenVideo(0);
  }

  @override
  void dispose() {
    _fallback?.cancel();
    _generation++;
    final controller = _controller;
    controller?.removeListener(handleTick);
    controller?.dispose();
    super.dispose();
  }

  void handleOpenStory(int index) {
    _fallback?.cancel();
    _didAdvance = false;
    setState(() {
      _index = index;
      _progress = 0;
    });
    widget.onVideoChange?.call(index);
    handleOpenVideo(index);
  }

  Future<void> handleOpenVideo(int index) async {
    final generation = ++_generation;
    final previous = _controller;
    previous?.removeListener(handleTick);
    _controller = null;
    if (previous != null) {
      unawaited(previous.dispose());
    }
    try {
      final next = VideoPlayerController.asset(
        storyBackgroundVideos[index],
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await next.initialize();
      if (!mounted || generation != _generation) {
        await next.dispose();
        return;
      }
      await next.setVolume(0);
      await next.setLooping(false);
      next.addListener(handleTick);
      setState(() => _controller = next);
      await next.play();
    } catch (_) {
      // Sem vídeo o slide ainda avança no fallback.
      if (!mounted || generation != _generation) {
        return;
      }
      handleArmFallback();
    }
  }

  void handleArmFallback() {
    _fallback?.cancel();
    _fallback = Timer(storyBackgroundFallbackDuration, handleGoToNext);
  }

  void handleTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration.inMilliseconds <= 0) {
      return;
    }
    final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );
    if ((progress - _progress).abs() > 0.01) {
      setState(() => _progress = progress);
    }
    final ended =
        controller.value.isCompleted ||
        (progress >= 0.97 && !controller.value.isPlaying);
    if (ended) {
      handleGoToNext();
    }
  }

  void handleGoToNext() {
    if (_didAdvance || !mounted) {
      return;
    }
    _didAdvance = true;
    _fallback?.cancel();
    handleOpenStory((_index + 1) % storyBackgroundVideos.length);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    return ColoredBox(
      color: AppPalette.platinum950,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            IgnorePointer(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          StoryBackgroundProgress(
            currentIndex: _index,
            isSecondStory: _index == 1,
            progress: _progress,
            top: MediaQuery.paddingOf(context).top + 12,
          ),
        ],
      ),
    );
  }
}
