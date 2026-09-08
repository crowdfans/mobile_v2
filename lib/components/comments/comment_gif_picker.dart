import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter/material.dart';

/// Modal de escolha de GIF (Tenor) para o comentário.
class CommentGifPicker extends StatelessWidget {
  const CommentGifPicker({
    super.key,
    required this.query,
    required this.items,
    required this.loading,
    required this.onQueryChanged,
    required this.onClose,
    required this.onSelect,
  });

  final String query;
  final List<CommentGifItem> items;
  final bool loading;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClose;
  final ValueChanged<CommentGifItem> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: onClose,
                    child: Text(
                      'Fechar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Escolher GIF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppTextField(
                hint: 'Buscar GIF',
                initialValue: query,
                onChanged: onQueryChanged,
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () => onSelect(item),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.previewUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
