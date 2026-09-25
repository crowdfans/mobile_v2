import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum _VideoUiState { idle, loading, ready, buffering, error }

/// Prévia de vídeo no feed com estados loaded / buffering / erro.
class PostVideoPreview extends StatefulWidget {
  const PostVideoPreview({
    super.key,
    this.thumbnailUri,
    this.videoUri,
    this.duration,
  });

  final String? thumbnailUri;
  final String? videoUri;
  final String? duration;

  @override
  State<PostVideoPreview> createState() => _PostVideoPreviewState();
}

class _PostVideoPreviewState extends State<PostVideoPreview> {
  VideoPlayerController? _controller;
  var _state = _VideoUiState.idle;
  var _muted = true;
  String? _errorMessage;

  String get _thumb => widget.thumbnailUri?.trim() ?? '';
  String get _video => widget.videoUri?.trim() ?? '';

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !mounted) {
      return;
    }
    if (c.value.hasError) {
      setState(() {
        _state = _VideoUiState.error;
        _errorMessage = 'Não foi possível reproduzir o vídeo.';
      });
      return;
    }
    if (c.value.isBuffering && c.value.isPlaying) {
      if (_state != _VideoUiState.buffering) {
        setState(() => _state = _VideoUiState.buffering);
      }
      return;
    }
    if (c.value.isInitialized && _state == _VideoUiState.buffering) {
      setState(() => _state = _VideoUiState.ready);
    }
  }

  Future<void> handleTogglePlay() async {
    if (_video.isEmpty) {
      setState(() {
        _state = _VideoUiState.error;
        _errorMessage = 'Vídeo indisponível.';
      });
      return;
    }
    if (_controller == null) {
      setState(() {
        _state = _VideoUiState.loading;
        _errorMessage = null;
      });
      final controller = VideoPlayerController.networkUrl(Uri.parse(_video));
      _controller = controller;
      controller.addListener(_onTick);
      try {
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setVolume(_muted ? 0 : 1);
        if (!mounted) {
          return;
        }
        setState(() => _state = _VideoUiState.ready);
        await controller.play();
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _state = _VideoUiState.error;
          _errorMessage = 'Falha ao carregar o vídeo.';
        });
      }
      return;
    }
    final c = _controller!;
    if (!c.value.isInitialized) {
      return;
    }
    if (c.value.isPlaying) {
      await c.pause();
      setState(() => _state = _VideoUiState.ready);
    } else {
      await c.play();
      setState(() => _state = _VideoUiState.ready);
    }
  }

  Future<void> handleToggleMute() async {
    setState(() => _muted = !_muted);
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      await c.setVolume(_muted ? 0 : 1);
    }
  }

  String durationLabel() {
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      final total = c.value.duration;
      final pos = c.value.position;
      String fmt(Duration d) {
        final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
        final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
        return '$m:$s';
      }
      if (c.value.isPlaying) {
        return fmt(pos);
      }
      return fmt(total);
    }
    final raw = (widget.duration ?? '').trim();
    return raw.isEmpty ? '00:00' : raw;
  }

  @override
  Widget build(BuildContext context) {
    final playing = _controller?.value.isPlaying == true;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller != null &&
                _controller!.value.isInitialized &&
                _state != _VideoUiState.error)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else if (_thumb.isNotEmpty)
              Image.network(
                _thumb,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
              )
            else
              const ColoredBox(color: Colors.black),
            if (_state == _VideoUiState.loading ||
                _state == _VideoUiState.buffering)
              const ColoredBox(
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
            if (_state == _VideoUiState.error)
              ColoredBox(
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
                          _errorMessage ?? 'Erro no vídeo',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: handleTogglePlay,
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
            if (_state != _VideoUiState.error &&
                _state != _VideoUiState.loading &&
                _state != _VideoUiState.buffering)
              Center(
                child: Material(
                  color: const Color(0x8C000000),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: handleTogglePlay,
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
                  customBorder: const CircleBorder(),
                  onTap: handleToggleMute,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      _muted
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
                    durationLabel(),
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
