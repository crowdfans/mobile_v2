import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/comment_gif_service.dart';
import 'package:flutter/material.dart';

/// Sheet de escolha de GIF (Tenor) com busca, vazio e erro recuperável.
class CommentGifPicker extends StatefulWidget {
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
  State<CommentGifPicker> createState() => _CommentGifPickerState();
}

class _CommentGifPickerState extends State<CommentGifPicker> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant CommentGifPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _queryController.text) {
      _queryController.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void handleClearQuery() {
    setState(() => _queryController.clear());
    widget.onQueryChanged('');
  }

  void handleQueryChanged(String value) {
    setState(() {});
    widget.onQueryChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final hasError = (widget.errorMessage ?? '').trim().isNotEmpty;
    final empty = !widget.loading && !hasError && widget.items.isEmpty;
    final queryText = _queryController.text;
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
                            onPressed: widget.onClose,
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
                      child: KeyedSubtree(
                        key: const Key('comment-gif-search'),
                        child: TextField(
                          controller: _queryController,
                          onChanged: handleQueryChanged,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Buscar GIF',
                            hintStyle: TextStyle(color: colors.textTertiary),
                            filled: true,
                            fillColor: colors.inputBackground,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              key: const Key('comment-gif-search-icon'),
                              color: colors.textTertiary,
                              size: 20,
                            ),
                            suffixIcon: queryText.trim().isEmpty
                                ? null
                                : Semantics(
                                    button: true,
                                    label: 'Limpar busca de GIF',
                                    child: IconButton(
                                      key: const Key('comment-gif-clear'),
                                      onPressed: handleClearQuery,
                                      icon: Icon(
                                        Icons.close,
                                        color: colors.textSecondary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.inputBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.primary),
                            ),
                          ),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if ((widget.resultAnnouncement ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          widget.resultAnnouncement!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: widget.loading
                        ? const Center(child: CircularProgressIndicator())
                        : hasError
                        ? Padding(
                            key: const Key('comment-gif-error'),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Text(
                              widget.errorMessage!,
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
                            key: const Key('comment-gif-empty'),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                queryText.trim().isEmpty
                                    ? 'Nenhum GIF em destaque no momento.'
                                    : 'Nenhum GIF encontrado para “${queryText.trim()}”.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            key: const Key('comment-gif-grid'),
                            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemCount: widget.items.length,
                            itemBuilder: (context, index) {
                              final item = widget.items[index];
                              final name = (item.label ?? '').trim().isEmpty
                                  ? 'GIF ${index + 1} de ${widget.items.length}'
                                  : item.label!;
                              return Semantics(
                                button: true,
                                label: name,
                                child: GestureDetector(
                                  key: Key('comment-gif-result-$index'),
                                  onTap: () => widget.onSelect(item),
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
