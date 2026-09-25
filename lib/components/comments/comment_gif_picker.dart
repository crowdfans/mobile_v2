import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter/material.dart';

/// Sheet de escolha de GIF (Tenor) com busca, vazio e erro recuperável.
class CommentGifPicker extends StatelessWidget {
  const CommentGifPicker({
    super.key,
    required this.query,
    required this.items,
    required this.loading,
    required this.onQueryChanged,
    required this.onClose,
    required this.onSelect,
    this.errorMessage,
    this.resultAnnouncement,
  });

  final String query;
  final List<CommentGifItem> items;
  final bool loading;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClose;
  final ValueChanged<CommentGifItem> onSelect;
  final String? errorMessage;
  final String? resultAnnouncement;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final hasError = (errorMessage ?? '').trim().isNotEmpty;
    final empty = !loading && !hasError && items.isEmpty;
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.78,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const SizedBox(width: 40, height: 4),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: Text(
                              'Escolher GIF',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'Fonte: Tenor',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          button: true,
                          label: 'Fechar seletor de GIF',
                          child: IconButton(
                            onPressed: onClose,
                            icon: Icon(Icons.close, color: colors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Semantics(
                      textField: true,
                      label: 'Buscar GIF',
                      child: AppTextField(
                        hint: 'Buscar GIF',
                        label: 'Buscar GIF',
                        initialValue: query,
                        onChanged: onQueryChanged,
                      ),
                    ),
                  ),
                  if ((resultAnnouncement ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          resultAnnouncement!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : hasError
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: colors.danger,
                              ),
                            ),
                          )
                        : empty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                query.trim().isEmpty
                                    ? 'Nenhum GIF em destaque no momento.'
                                    : 'Nenhum GIF encontrado para “${query.trim()}”.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Semantics(
                                button: true,
                                label: 'GIF ${index + 1} de ${items.length}',
                                child: GestureDetector(
                                  onTap: () => onSelect(item),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.previewUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stack) =>
                                          ColoredBox(
                                            color: colors.surfaceAlt,
                                            child: Icon(
                                              Icons.broken_image_outlined,
                                              color: colors.textTertiary,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
