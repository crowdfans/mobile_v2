import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_backgrounds_sheet.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_canvas_preview.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_confirm_dialog.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_recipient_bar.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_stickers_sheet.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_tool_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

enum _ComposeTool { none, draw, text }

/// Compose de Fan Letter alinhado ao mock Superfã (canvas + ferramentas).
class FanLetterComposeScreen extends StatefulWidget {
  const FanLetterComposeScreen({
    super.key,
    this.artistId,
    this.artistName,
    this.avatarUrl,
  });

  final String? artistId;
  final String? artistName;
  final String? avatarUrl;

  @override
  State<FanLetterComposeScreen> createState() => _FanLetterComposeScreenState();
}

class _FanLetterComposeScreenState extends State<FanLetterComposeScreen> {
  static const _drawColors = [
    Color(0xFF111827),
    Color(0xFFFFFFFF),
    Color(0xFFFF2D87),
    Color(0xFF7E49FF),
    Color(0xFF48C7FF),
    Color(0xFF24FB20),
    Color(0xFFFFE50D),
    Color(0xFFFF920A),
    Color(0xFFFF2C20),
  ];

  final _canvasKey = GlobalKey();
  final _textController = TextEditingController();
  var _bodyText = '';
  var _backgroundId = fanLetterBackgroundPresets.first.id;
  var _saving = false;
  var _tool = _ComposeTool.none;
  var _drawColor = _drawColors.first;
  var _strokeWidth = 6.0;
  var _erasing = false;
  FanLetterMonetization? _monetization;
  final _stickers = <FanLetterPlacedSticker>[];
  final _strokes = <FanLetterStroke>[];
  FanLetterStroke? _activeStroke;
  var _stickerNonce = 0;

  String get _artistId => widget.artistId?.trim() ?? '';

  FanLetterBackgroundPreset get _preset {
    return fanLetterBackgroundPresets.firstWhere(
      (item) => item.id == _backgroundId,
      orElse: () => fanLetterBackgroundPresets.first,
    );
  }

  bool get _hasContent {
    return _bodyText.trim().isNotEmpty ||
        _stickers.isNotEmpty ||
        _strokes.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    handleLoadMonetization();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.fanLetterGallery);
  }

  Future<void> handleLoadMonetization() async {
    if (_artistId.isEmpty) {
      return;
    }
    try {
      final monetization = await FanLetterService.getMonetization(_artistId);
      if (!mounted) {
        return;
      }
      setState(() => _monetization = monetization);
    } catch (_) {
      if (mounted) {
        setState(() => _monetization = null);
      }
    }
  }

  Future<void> handleOpenStickers() async {
    setState(() => _tool = _ComposeTool.none);
    final asset = await FanLetterStickersSheet.present(context);
    if (asset == null || !mounted) {
      return;
    }
    setState(() {
      _stickerNonce++;
      _stickers.add(
        FanLetterPlacedSticker(
          id: 's$_stickerNonce',
          asset: asset,
          offset: Offset(80 + (_stickerNonce % 4) * 18.0, 140 + (_stickerNonce % 3) * 24.0),
        ),
      );
    });
  }

  Future<void> handleOpenBackgrounds() async {
    setState(() => _tool = _ComposeTool.none);
    final id = await FanLetterBackgroundsSheet.present(
      context,
      selectedId: _backgroundId,
    );
    if (id == null || !mounted) {
      return;
    }
    setState(() => _backgroundId = id);
  }

  void handleToggleDraw() {
    setState(() {
      _tool = _tool == _ComposeTool.draw ? _ComposeTool.none : _ComposeTool.draw;
    });
  }

  void handleToggleText() {
    setState(() {
      _tool = _tool == _ComposeTool.text ? _ComposeTool.none : _ComposeTool.text;
      if (_tool == _ComposeTool.text) {
        _textController.text = _bodyText;
        _textController.selection = TextSelection.collapsed(
          offset: _textController.text.length,
        );
      }
    });
  }

  void handleUndoStroke() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() => _strokes.removeLast());
  }

  Future<void> handleRecipientInfo() async {
    final hint = monetizationHint();
    await AppAlert.show(
      context,
      title: widget.artistName?.trim().isEmpty == false
          ? widget.artistName!.trim()
          : 'Destinatário',
      message: hint ??
          (_artistId.isEmpty
              ? 'Abra o compose pelo perfil do artista para escolher o destinatário.'
              : 'Membership e saldo de Jam Coins entram no envio desta carta.'),
    );
  }

  String? monetizationHint() {
    final data = _monetization;
    if (data == null) {
      return null;
    }
    if (data.isMember) {
      return 'Membership ativa: envio gratuito.';
    }
    if (data.freeLettersUsed >= data.freeLettersLimit) {
      return 'Cota grátis esgotada. Este envio custa ${data.jamCoinsCost} Jam Coins (saldo ${data.jamCoinsBalance}).';
    }
    return 'Cartas grátis ${data.freeLettersUsed}/${data.freeLettersLimit}. Depois, ${data.jamCoinsCost} Jam Coins.';
  }

  Future<Uint8List?> captureCanvasPng() async {
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  Future<void> handleSendTap() async {
    if (_artistId.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Fan Letter',
        message: 'Selecione um artista (abra pelo perfil).',
      );
      return;
    }
    if (!_hasContent) {
      await AppAlert.show(
        context,
        title: 'Carta vazia',
        message: 'Adicione pelo menos um elemento na carta antes de enviar.',
      );
      return;
    }
    setState(() => _tool = _ComposeTool.none);
    final confirmed = await FanLetterConfirmDialog.present(
      context,
      preset: _preset,
      artistName: widget.artistName ?? '',
      avatarUrl: widget.avatarUrl,
      preview: FanLetterCanvasPreview(
        preset: _preset,
        bodyText: _bodyText,
        stickers: _stickers,
        strokes: _strokes,
        compact: true,
      ),
    );
    if (!confirmed || !mounted) {
      return;
    }
    await handlePublish();
  }

  Future<void> handlePublish() async {
    setState(() => _saving = true);
    try {
      String? uploadedImageUri;
      final needsImage = _stickers.isNotEmpty || _strokes.isNotEmpty;
      if (needsImage) {
        final png = await captureCanvasPng();
        if (png != null) {
          uploadedImageUri = await MediaService.resolveMediaUrl(
            uri: 'fan-letter-${DateTime.now().millisecondsSinceEpoch}.png',
            kind: MediaKind.fanLetter,
            mimeType: 'image/png',
            bytes: png,
          );
        }
      }
      final text = _bodyText.trim();
      await FanLetterService.createFanLetter(
        CreateFanLetterRequest(
          artistId: _artistId,
          artistName: (widget.artistName ?? '').trim().isEmpty
              ? 'Artista'
              : widget.artistName!.trim(),
          artistAvatarUri: widget.avatarUrl?.trim().isEmpty == true
              ? null
              : widget.avatarUrl?.trim(),
          bodyText: text.isEmpty ? null : text,
          imageUri: uploadedImageUri,
          backgroundId: _backgroundId,
        ),
      );
      if (!mounted) {
        return;
      }
      await AppAlert.show(context, title: 'Fan Letter', message: 'Carta enviada!');
      if (!mounted) {
        return;
      }
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Pages.fanLetterGallery);
      }
    } on ApiError catch (error) {
      if (!mounted) {
        return;
      }
      await AppAlert.show(
        context,
        title: 'Fan Letter',
        message: error.status == 402
            ? 'Saldo de Jam Coins insuficiente. Recarregue a carteira e tente de novo.'
            : error.message,
      );
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Fan Letter',
          message: error.toString(),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void handleDrawStart(DragStartDetails details) {
    if (_tool != _ComposeTool.draw) {
      return;
    }
    setState(() {
      _activeStroke = FanLetterStroke(
        points: [details.localPosition],
        color: _erasing ? const Color(0x00FFFFFF) : _drawColor,
        width: _erasing ? _strokeWidth * 2.2 : _strokeWidth,
      );
      if (_erasing) {
        // Borracha simples: remove traços próximos.
        _strokes.removeWhere((stroke) {
          return stroke.points.any(
            (point) => (point - details.localPosition).distance < 28,
          );
        });
        _activeStroke = null;
      }
    });
  }

  void handleDrawUpdate(DragUpdateDetails details) {
    final active = _activeStroke;
    if (active == null) {
      return;
    }
    setState(() {
      _activeStroke = FanLetterStroke(
        points: [...active.points, details.localPosition],
        color: active.color,
        width: active.width,
      );
    });
  }

  void handleDrawEnd(DragEndDetails details) {
    final active = _activeStroke;
    if (active == null) {
      return;
    }
    setState(() {
      _strokes.add(active);
      _activeStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final monetization = _monetization;
    final strokes = [
      ..._strokes,
      ?_activeStroke,
    ];
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
              child: Column(
                children: [
                  Row(
                    children: [
                      FanLetterToolButton(
                        icon: Icons.close,
                        onPressed: handleBack,
                      ),
                      const Spacer(),
                      FanLetterToolButton(
                        icon: Icons.brush_rounded,
                        active: _tool == _ComposeTool.draw,
                        onPressed: handleToggleDraw,
                      ),
                      const SizedBox(width: 8),
                      FanLetterToolButton(
                        icon: Icons.title_rounded,
                        active: _tool == _ComposeTool.text,
                        onPressed: handleToggleText,
                      ),
                      const SizedBox(width: 8),
                      FanLetterToolButton(
                        icon: Icons.sticky_note_2_outlined,
                        onPressed: handleOpenStickers,
                      ),
                      const SizedBox(width: 8),
                      FanLetterToolButton(
                        icon: Icons.wallpaper_rounded,
                        onPressed: handleOpenBackgrounds,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RepaintBoundary(
                      key: _canvasKey,
                      child: GestureDetector(
                        onPanStart: _tool == _ComposeTool.draw
                            ? handleDrawStart
                            : null,
                        onPanUpdate: _tool == _ComposeTool.draw
                            ? handleDrawUpdate
                            : null,
                        onPanEnd: _tool == _ComposeTool.draw
                            ? handleDrawEnd
                            : null,
                        child: FanLetterCanvasPreview(
                          preset: _preset,
                          bodyText: _bodyText,
                          stickers: _stickers,
                          strokes: strokes,
                          onStickerMoved: (id, offset) {
                            setState(() {
                              final index = _stickers.indexWhere(
                                (item) => item.id == id,
                              );
                              if (index < 0) {
                                return;
                              }
                              _stickers[index] = _stickers[index].copyWith(
                                offset: offset,
                              );
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_tool == _ComposeTool.draw)
              Positioned(
                left: 16,
                top: 72,
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _erasing = false),
                            icon: Icon(
                              Icons.edit,
                              color: _erasing
                                  ? colors.textSecondary
                                  : colors.primary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _erasing = true),
                            icon: Icon(
                              Icons.auto_fix_off,
                              color: _erasing
                                  ? colors.primary
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: handleUndoStroke,
                      icon: Icon(Icons.undo, color: colors.textSecondary),
                    ),
                    RotatedBox(
                      quarterTurns: 3,
                      child: SizedBox(
                        width: 120,
                        child: Slider(
                          value: _strokeWidth,
                          min: 2,
                          max: 18,
                          onChanged: (value) {
                            setState(() => _strokeWidth = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_tool == _ComposeTool.draw)
              Positioned(
                right: 12,
                top: 80,
                child: Column(
                  children: [
                    for (final color in _drawColors) ...[
                      GestureDetector(
                        onTap: () => setState(() {
                          _drawColor = color;
                          _erasing = false;
                        }),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _drawColor == color
                                  ? colors.primary
                                  : colors.border,
                              width: _drawColor == color ? 2.5 : 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (_tool == _ComposeTool.text)
              Positioned.fill(
                child: Material(
                  color: const Color(0xCC2A2140),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FanLetterToolButton(
                                  icon: Icons.title_rounded,
                                  active: true,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 8),
                                FanLetterToolButton(
                                  icon: Icons.close,
                                  onPressed: () {
                                    setState(() => _tool = _ComposeTool.none);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextField(
                              controller: _textController,
                              autofocus: true,
                              maxLength: 290,
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterStyle: TextStyle(color: Colors.white70),
                              ),
                              onChanged: (value) {
                                setState(() => _bodyText = value);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: FilledButton(
                            onPressed: () {
                              setState(() => _tool = _ComposeTool.none);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text('Pronto'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: FanLetterRecipientBar(
                artistName: widget.artistName ?? '',
                avatarUrl: widget.avatarUrl,
                jamCoinsBalance: monetization?.jamCoinsBalance,
                jamCoinsCost: monetization?.jamCoinsCost,
                isMember: monetization?.isMember ?? false,
                sending: _saving,
                onRecipientTap: handleRecipientInfo,
                onSend: handleSendTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
