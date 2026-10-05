import 'package:crowdfans/components/post/post_video_preview_chrome.dart';
import 'package:crowdfans/components/post/post_video_ui_state.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Prévia de vídeo no feed com estados loaded / buffering / erro (CF-232).
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
  var _state = PostVideoUiState.idle;
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
        _state = PostVideoUiState.error;
        _errorMessage = 'Não foi possível reproduzir o vídeo.';
      });
      return;
    }
    if (c.value.isBuffering && c.value.isPlaying) {
      if (_state != PostVideoUiState.buffering) {
        setState(() => _state = PostVideoUiState.buffering);
      }
      return;
    }
    if (c.value.isInitialized && _state == PostVideoUiState.buffering) {
      setState(() => _state = PostVideoUiState.ready);
    }
  }

  Future<void> handleTogglePlay() async {
    if (_video.isEmpty) {
      setState(() {
        _state = PostVideoUiState.error;
        _errorMessage = 'Vídeo indisponível.';
      });
      return;
    }
    if (_controller == null) {
      setState(() {
        _state = PostVideoUiState.loading;
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
        setState(() => _state = PostVideoUiState.ready);
        await controller.play();
      } catch (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _state = PostVideoUiState.error;
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
      setState(() => _state = PostVideoUiState.ready);
    } else {
      await c.play();
      setState(() => _state = PostVideoUiState.ready);
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

  Widget _buildMediaChild() {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        _state != PostVideoUiState.error) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      );
    }
    if (_thumb.isNotEmpty) {
      return Image.network(
        _thumb,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
      );
    }
    return const ColoredBox(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final playing = _controller?.value.isPlaying == true;
    return Semantics(
      key: const Key('post-video'),
      label: switch (_state) {
        PostVideoUiState.idle || PostVideoUiState.ready =>
          playing ? 'Vídeo em reprodução' : 'Vídeo pronto',
        PostVideoUiState.loading => 'Vídeo carregando',
        PostVideoUiState.buffering => 'Vídeo buffering',
        PostVideoUiState.error => 'Vídeo com erro',
      },
      child: PostVideoPreviewChrome(
        state: _state,
        muted: _muted,
        playing: playing,
        durationLabel: durationLabel(),
        errorMessage: _errorMessage,
        onTogglePlay: handleTogglePlay,
        onToggleMute: handleToggleMute,
        mediaChild: _buildMediaChild(),
      ),
    );
  }
}
