import 'dart:typed_data';

import 'package:crowdfans/components/post/post_avatar.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Área avatar + texto + preview de mídia do Novo Post.
class NovoPostComposerBody extends StatelessWidget {
  const NovoPostComposerBody({
    super.key,
    required this.avatarUrl,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFocus,
    this.imageBytes,
    this.imageUrl,
    this.isVideo = false,
    this.onRemoveImage,
  });

  final String avatarUrl;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocus;
  final Uint8List? imageBytes;
  final String? imageUrl;
  final bool isVideo;
  final VoidCallback? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final hasImage =
        (imageBytes != null && imageBytes!.isNotEmpty) ||
        ((imageUrl ?? '').startsWith('http'));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostAvatar(url: avatarUrl, size: 52),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                key: const Key('novo-post-content'),
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onTap: onFocus,
                autofocus: true,
                maxLines: null,
                maxLength: 280,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => const SizedBox.shrink(),
                style: TextStyle(
                  fontSize: 17,
                  height: 1.35,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'O que quer postar hoje?',
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              if (hasImage) ...[
                const SizedBox(height: 12),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isVideo
                          ? ColoredBox(
                              color: colors.surfaceAlt,
                              child: SizedBox(
                                width: double.infinity,
                                height: 180,
                                child: Center(
                                  child: Text(
                                    'Vídeo selecionado',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : imageBytes != null && imageBytes!.isNotEmpty
                          ? Image.memory(
                              imageBytes!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              imageUrl!,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (onRemoveImage != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onRemoveImage,
                            child: const SizedBox(
                              width: 28,
                              height: 28,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
