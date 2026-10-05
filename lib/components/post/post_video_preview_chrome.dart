import 'package:crowdfans/components/post/post_video_ui_state.dart';
import 'package:flutter/material.dart';

/// Chrome do player (mute, duração, play/pause, spinner, erro) — CF-232.
///
/// Separado do [VideoPlayerController] para testes green/red/edge sem rede.
class PostVideoPreviewChrome extends StatelessWidget {
  const PostVideoPreviewChrome({
    super.key,
    required this.state,
    required this.muted,
    required this.playing,
    required this.durationLabel,
    this.errorMessage,
    this.onTogglePlay,
    this.onToggleMute,
    this.mediaChild,
  });

  final PostVideoUiState state;
  final bool muted;
  final bool playing;
  final String durationLabel;
  final String? errorMessage;
  final VoidCallback? onTogglePlay;
  final VoidCallback? onToggleMute;

  /// Frame do vídeo / thumbnail / fundo (atrás dos controles).
  final Widget? mediaChild;

  bool get _showSpinner =>
      state == PostVideoUiState.loading || state == PostVideoUiState.buffering;

  bool get _showError => state == PostVideoUiState.error;

  bool get _showCenterPlay =>
      !_showSpinner && !_showError;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            mediaChild ?? const ColoredBox(color: Colors.black),
            if (_showSpinner)
              const ColoredBox(
                key: Key('post-video-buffering'),
                color: Color(0x66000000),
                child: Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (_showError)
              ColoredBox(
                key: const Key('post-video-error'),
                color: const Color(0x99000000),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_disabled_rounded,
                          size: 40,
                          color: Colors.white70,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage ?? 'Erro no vídeo',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: onTogglePlay,
                          child: const Text(
                            'Tentar de novo',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_showCenterPlay)
              Center(
                child: Material(
                  color: const Color(0x8C000000),
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const Key('post-video-play'),
                    customBorder: const CircleBorder(),
                    onTap: onTogglePlay,
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_disabled_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: const Color(0x80000000),
                shape: const CircleBorder(),
                child: InkWell(
                  key: const Key('post-video-mute'),
                  customBorder: const CircleBorder(),
                  onTap: onToggleMute,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      muted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: DecoratedBox(
                key: const Key('post-video-duration'),
                decoration: BoxDecoration(
                  color: const Color(0x8C000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    durationLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
