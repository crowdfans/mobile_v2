import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Área pontilhada para escolher/trocar a imagem do post.
class CreatePostImagePicker extends StatelessWidget {
  const CreatePostImagePicker({
    super.key,
    required this.hasImage,
    required this.onPressed,
  });

  final bool hasImage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Material(
      color: colors.inputBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.inputBorder, width: 2),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              hasImage ? '📷 Trocar imagem' : '📷 Selecionar imagem',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
