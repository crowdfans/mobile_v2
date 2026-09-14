import 'dart:typed_data';

import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/post/create_post_exclusive_toggle.dart';
import 'package:crowdfans/components/post/create_post_feedback_banner.dart';
import 'package:crowdfans/components/post/create_post_image_picker.dart';
import 'package:crowdfans/components/post/create_post_preview.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/feed_post.dart';
import 'package:crowdfans/services/media_service.dart';
import 'package:crowdfans/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Criação e edição de post (texto + mídia opcional).
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.postId, this.targetArtistId});

  final String? postId;
  final String? targetArtistId;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

/// Tipo do post a partir do conteúdo (CF-141 — sem menu texto/imagem).
PostType resolveCreatePostType({required bool hasMedia}) {
  return hasMedia ? PostType.image : PostType.text;
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  var _text = '';
  String? _selectedImageUri;
  Uint8List? _selectedImageBytes;
  String? _selectedImageMime;
  var _isExclusive = false;
  var _loading = false;
  var _hydrating = false;
  String? _error;
  String? _success;

  bool get _isEdit => (widget.postId ?? '').isNotEmpty;

  bool get _isFanClubPost => (widget.targetArtistId ?? '').trim().isNotEmpty;

  bool get _hasMedia =>
      _selectedImageUri != null && _selectedImageUri!.isNotEmpty;

  bool get _canPublish =>
      (_text.trim().isNotEmpty || _hasMedia) && _text.length <= 280;

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
        _text = post.text;
        _selectedImageUri = post.imageUri;
        _selectedImageBytes = null;
        _isExclusive = post.isExclusive;
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

  void handleClearImage() {
    setState(() {
      _selectedImageUri = null;
      _selectedImageBytes = null;
      _selectedImageMime = null;
      _error = null;
    });
  }

  bool validatePost() {
    if (_text.length > 280) {
      setState(() => _error = 'O post pode ter no máximo 280 caracteres');
      return false;
    }
    if (_text.trim().isEmpty && !_hasMedia) {
      setState(() => _error = 'Escreva um texto ou adicione uma imagem');
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
      final type = resolveCreatePostType(hasMedia: imageUri != null && imageUri.isNotEmpty);
      final payload = PostWriteRequest(
        type: type,
        text: _text.trim(),
        imageUri: imageUri,
        targetArtistId: widget.targetArtistId,
        isExclusive: _isExclusive,
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
                        : _isFanClubPost
                        ? 'Post no Fã Clube'
                        : 'Escreva a descrição e, se quiser, adicione uma imagem.',
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    CreatePostFeedbackBanner(message: _error!, success: false),
                  if (_success != null)
                    CreatePostFeedbackBanner(message: _success!, success: true),
                  KeyedSubtree(
                    key: const Key('create-post-content'),
                    child: AppTextField(
                      key: ValueKey(widget.postId ?? 'new-post'),
                      label: 'Descrição',
                      hint: 'O que você quer compartilhar?',
                      maxLines: 6,
                      maxLength: 280,
                      initialValue: _text,
                      onChanged: handleTextChange,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_text.length}/280',
                      style: TextStyle(
                        fontSize: 12,
                        color: _text.length > 280
                            ? colors.danger
                            : colors.textTertiary,
                      ),
                    ),
                  ),
                  if (!_isFanClubPost) ...[
                    const SizedBox(height: 8),
                    CreatePostExclusiveToggle(
                      value: _isExclusive,
                      onChanged: (value) {
                        setState(() => _isExclusive = value);
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Mídia (opcional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CreatePostImagePicker(
                    key: const Key('create-post-add-image'),
                    hasImage: _hasMedia,
                    onPressed: handlePickImage,
                  ),
                  if (_hasMedia) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const Key('create-post-clear-image'),
                        onPressed: handleClearImage,
                        child: Text(
                          'Remover imagem',
                          style: TextStyle(color: colors.danger),
                        ),
                      ),
                    ),
                  ],
                  if (_text.trim().isNotEmpty || _hasMedia) ...[
                    const SizedBox(height: 24),
                    CreatePostPreview(
                      text: _text,
                      hasImage: _hasMedia,
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
                      key: const Key('create-post-submit'),
                      label: _isEdit ? 'Salvar alterações' : 'Publicar Post',
                      disabled: !_canPublish,
                      onPressed: handlePublish,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
