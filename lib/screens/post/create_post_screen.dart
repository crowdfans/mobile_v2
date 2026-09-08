import 'dart:typed_data';

import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/post/create_post_feedback_banner.dart';
import 'package:crowdfans/components/post/create_post_image_picker.dart';
import 'package:crowdfans/components/post/create_post_preview.dart';
import 'package:crowdfans/components/post/create_post_type_chip.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Criação e edição de post (texto, imagem, carrossel, vídeo, membership).
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.postId, this.targetArtistId});

  final String? postId;
  final String? targetArtistId;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  PostType? _selectedType;
  var _text = '';
  String? _selectedImageUri;
  Uint8List? _selectedImageBytes;
  String? _selectedImageMime;
  var _loading = false;
  var _hydrating = false;
  String? _error;
  String? _success;

  bool get _isEdit => (widget.postId ?? '').isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _hydrating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleLoadPost();
      });
    }
  }

  Future<void> handleLoadPost() async {
    final postId = widget.postId;
    if (postId == null || postId.isEmpty) {
      return;
    }
    setState(() {
      _hydrating = true;
      _error = null;
    });
    try {
      final post = await PostService.getPostById(postId);
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedType = post.type == PostType.unknown
            ? PostType.text
            : post.type;
        _text = post.text;
        _selectedImageUri = post.imageUri;
        _selectedImageBytes = null;
        _hydrating = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hydrating = false;
        _error = error.toString();
      });
    }
  }

  void handleSelectType(PostType type) {
    setState(() {
      _selectedType = type;
      _error = null;
    });
  }

  void handleTextChange(String value) {
    setState(() {
      _text = value;
      _error = null;
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
        _selectedImageUri = file.path.isNotEmpty ? file.path : file.name;
        _selectedImageBytes = bytes;
        _selectedImageMime = file.mimeType;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.toString());
    }
  }

  bool validatePost() {
    if (_selectedType == null) {
      setState(() => _error = 'Por favor, selecione um tipo de post');
      return false;
    }
    if (_text.trim().isEmpty) {
      setState(() => _error = 'O conteúdo do post não pode estar vazio');
      return false;
    }
    if ((_selectedType == PostType.image ||
            _selectedType == PostType.carousel) &&
        (_selectedImageUri == null || _selectedImageUri!.isEmpty)) {
      setState(() => _error = 'Por favor, selecione pelo menos uma imagem');
      return false;
    }
    return true;
  }

  Future<void> handlePublish() async {
    if (!validatePost()) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      String? imageUri;
      if (_selectedImageUri != null && _selectedImageUri!.isNotEmpty) {
        imageUri = await MediaService.resolveMediaUrl(
          uri: _selectedImageUri!,
          kind: MediaKind.post,
          mimeType: _selectedImageMime,
          bytes: _selectedImageBytes,
        );
      }
      final payload = PostWriteRequest(
        type: _selectedType!,
        text: _text.trim(),
        imageUri: imageUri,
        targetArtistId: widget.targetArtistId,
      );
      if (_isEdit) {
        await PostService.updatePost(widget.postId!, payload);
      } else {
        await PostService.createPost(payload);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _success = _isEdit
            ? 'Post atualizado com sucesso!'
            : 'Post publicado com sucesso!';
      });
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) {
        return;
      }
      context.go(Pages.myPosts);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    if (_hydrating) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final needsImage =
        _selectedType == PostType.image || _selectedType == PostType.carousel;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  if (context.canPop())
                    ToolbarBackButton(onPressed: () => context.pop()),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  Text(
                    _isEdit ? 'Editar Post' : 'Criar Post',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isEdit
                        ? 'Atualize o conteúdo e publique novamente'
                        : 'Compartilhe seu conteúdo com seus fãs',
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    CreatePostFeedbackBanner(message: _error!, success: false),
                  if (_success != null)
                    CreatePostFeedbackBanner(message: _success!, success: true),
                  Text(
                    'Tipo de Post',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final type in createPostTypes)
                        CreatePostTypeChip(
                          type: type,
                          selected: _selectedType == type,
                          onPressed: () => handleSelectType(type),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AppTextField(
                    key: ValueKey(widget.postId ?? 'new-post'),
                    label: 'Conteúdo',
                    hint: 'Digite o conteúdo do seu post...',
                    maxLines: 6,
                    initialValue: _text,
                    onChanged: handleTextChange,
                  ),
                  if (needsImage) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Imagem',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CreatePostImagePicker(
                      hasImage:
                          _selectedImageUri != null &&
                          _selectedImageUri!.isNotEmpty,
                      onPressed: handlePickImage,
                    ),
                  ],
                  if (_selectedType != null && _text.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    CreatePostPreview(
                      text: _text,
                      hasImage:
                          _selectedImageUri != null &&
                          _selectedImageUri!.isNotEmpty,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: _loading
                  ? Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          _isEdit ? 'Salvando post...' : 'Publicando post...',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    )
                  : AppButton(
                      label: _isEdit ? 'Salvar alterações' : 'Publicar Post',
                      disabled: _selectedType == null || _text.trim().isEmpty,
                      onPressed: handlePublish,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
