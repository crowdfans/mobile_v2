import 'package:crowdfans/components/post/novo_post_media_toolbar_button.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Barra fixa acima do teclado: álbum | câmera | vídeo | contador.
class NovoPostMediaToolbar extends StatelessWidget {
  const NovoPostMediaToolbar({
    super.key,
    required this.remainingCharacters,
    required this.onPickGallery,
    required this.onTakePhoto,
    required this.onPickVideo,
  });

  final int remainingCharacters;
  final VoidCallback onPickGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback onPickVideo;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    // CF-179: sobe com o teclado (mesmo padrão CF-196); sem teclado
    // usa a área segura inferior.
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottomPad = keyboardInset > 0 ? keyboardInset : safeBottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomPad),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
          child: Row(
            children: [
              NovoPostMediaToolbarButton(
                key: const Key('novo-post-gallery'),
                asset: 'assets/icons/Images/image-01.svg',
                onPressed: onPickGallery,
              ),
              NovoPostMediaToolbarButton(
                key: const Key('novo-post-camera'),
                asset: 'assets/icons/Images/camera-01.svg',
                onPressed: onTakePhoto,
              ),
              NovoPostMediaToolbarButton(
                key: const Key('novo-post-video'),
                asset: 'assets/icons/Media & devices/play-square.svg',
                onPressed: onPickVideo,
              ),
              const Spacer(),
              Semantics(
                label: 'Caracteres restantes: $remainingCharacters',
                child: Text(
                  key: const Key('novo-post-char-counter'),
                  '$remainingCharacters',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: remainingCharacters < 0
                        ? colors.danger
                        : colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
