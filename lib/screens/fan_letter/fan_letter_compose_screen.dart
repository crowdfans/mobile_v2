import 'dart:typed_data';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_background_chip.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_preview_card.dart';
import 'package:crowdfans/components/fan_letter/fan_letter_sticker_chip.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Compose de fan letter com fundos e stickers.
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
  var _bodyText = '';
  var _imageUri = '';
  Uint8List? _imageBytes;
  String? _imageMime;
  var _backgroundId = fanLetterBackgroundPresets.first.id;
  var _saving = false;
  var _fieldNonce = 0;
  FanLetterMonetization? _monetization;

  String get _artistId => widget.artistId?.trim() ?? '';

  FanLetterBackgroundPreset get _preset {
    return fanLetterBackgroundPresets.firstWhere(
      (item) => item.id == _backgroundId,
      orElse: () => fanLetterBackgroundPresets.first,
    );
  }

  @override
  void initState() {
    super.initState();
    handleLoadMonetization();
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

  void handleInsertSticker(String emoji) {
    setState(() {
      _bodyText = '$_bodyText$emoji';
      _fieldNonce++;
    });
  }

  Future<void> handlePickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _imageUri = file.path.isNotEmpty ? file.path : file.name;
        _imageBytes = bytes;
        _imageMime = file.mimeType;
      });
    } catch (error) {
      if (mounted) {
        await AppAlert.show(
          context,
          title: 'Fan Letter',
          message: error.toString(),
        );
      }
    }
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

  Future<void> handlePublish() async {
    if (_artistId.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Fan Letter',
        message: 'Selecione um artista (abra pelo perfil).',
      );
      return;
    }
    final text = _bodyText.trim();
    final image = _imageUri.trim();
    if (text.isEmpty && image.isEmpty) {
      await AppAlert.show(
        context,
        title: 'Fan Letter',
        message: 'Escreva uma mensagem ou anexe uma imagem.',
      );
      return;
    }
    setState(() => _saving = true);
    try {
      String? uploadedImageUri;
      if (image.isNotEmpty) {
        uploadedImageUri = await MediaService.resolveMediaUrl(
          uri: image,
          kind: MediaKind.fanLetter,
          mimeType: _imageMime,
          bytes: _imageBytes,
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final hint = monetizationHint();
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  TextButton(
                    onPressed: handleBack,
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Fan Letter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  Text(
                    'Para: ${(widget.artistName ?? '').trim().isEmpty ? 'Artista' : widget.artistName}',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      hint,
                      style: TextStyle(fontSize: 12, color: colors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Fundo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in fanLetterBackgroundPresets)
                        FanLetterBackgroundChip(
                          preset: preset,
                          selected: _backgroundId == preset.id,
                          onPressed: () {
                            setState(() => _backgroundId = preset.id);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stickers',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final emoji in fanLetterStickerEmojis)
                        FanLetterStickerChip(
                          emoji: emoji,
                          onPressed: () => handleInsertSticker(emoji),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FanLetterPreviewCard(preset: _preset, bodyText: _bodyText),
                  const SizedBox(height: 16),
                  AppTextField(
                    key: ValueKey(_fieldNonce),
                    label: 'Mensagem',
                    hint: 'Escreva sua mensagem para o artista',
                    maxLines: 5,
                    initialValue: _bodyText,
                    onChanged: (value) => setState(() => _bodyText = value),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: _imageUri.isEmpty ? 'Anexar imagem' : 'Trocar imagem',
                    variant: AppButtonVariant.outline,
                    onPressed: handlePickImage,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: _saving ? 'Enviando...' : 'Enviar carta',
                    disabled: _saving,
                    onPressed: handlePublish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
