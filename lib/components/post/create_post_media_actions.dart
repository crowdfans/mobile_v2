import 'package:crowdfans/components/post/create_post_media_action_button.dart';
import 'package:flutter/material.dart';

/// Par de botões: adicionar imagem / adicionar música (CF-141).
class CreatePostMediaActions extends StatelessWidget {
  const CreatePostMediaActions({
    super.key,
    required this.hasImage,
    required this.hasMusic,
    required this.onAddImage,
    required this.onAddMusic,
  });

  final bool hasImage;
  final bool hasMusic;
  final VoidCallback onAddImage;
  final VoidCallback onAddMusic;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CreatePostMediaActionButton(
            key: const Key('create-post-add-image'),
            label: hasImage ? 'Trocar imagem' : 'Adicionar imagem',
            asset: 'assets/icons/Images/image-01.svg',
            selected: hasImage,
            onPressed: onAddImage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CreatePostMediaActionButton(
            key: const Key('create-post-add-music'),
            label: hasMusic ? 'Música adicionada' : 'Adicionar música',
            asset: 'assets/icons/Media & devices/music-note-01.svg',
            selected: hasMusic,
            onPressed: onAddMusic,
          ),
        ),
      ],
    );
  }
}
