import 'package:crowdfans/components/story/story_background_progress.dart';
import 'package:crowdfans/constants/story_background_videos.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Fundo em vídeo do onboarding (3 stories, tap esquerda/direita).
class StoryBackground extends StatefulWidget {
  const StoryBackground({super.key, this.onVideoChange});

  final ValueChanged<int>? onVideoChange;

  @override
  State<StoryBackground> createState() => _StoryBackgroundState();
}

class _StoryBackgroundState extends State<StoryBackground> {
  int _index = 0;
  VideoPlayerController? _controller;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _open(_index);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open(int index) async {
    final previous = _controller;
    previous?.removeListener(_onTick);
    final next = VideoPlayerController.asset(storyBackgroundVideos[index]);
    _controller = next;
    await next.initialize();
    if (!mounted || _controller != next) {
      await next.dispose();
      return;
    }
    next.setLooping(false);
    next.addListener(_onTick);
    await next.play();
    await previous?.dispose();
    if (!mounted) {
      return;
    }
    setState(() {
      _index = index;
      _progress = 0;
    });
    widget.onVideoChange?.call(index);
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final duration = controller.value.duration.inMilliseconds;
    final position = controller.value.position.inMilliseconds;
    if (duration <= 0) {
      return;
    }
    final progress = (position / duration).clamp(0.0, 1.0);
    if (controller.value.position >= controller.value.duration &&
        !controller.value.isPlaying) {
      goToNext();
      return;
    }
    if ((progress - _progress).abs() > 0.01) {
      setState(() => _progress = progress);
    }
  }

  void goToNext() {
    final next = (_index + 1) % storyBackgroundVideos.length;
    _open(next);
  }

  void goToPrevious() {
    final previous =
        (_index - 1 + storyBackgroundVideos.length) %
        storyBackgroundVideos.length;
    _open(previous);
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
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: goToPrevious,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: goToNext,
                ),
              ),
            ],
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
