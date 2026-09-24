import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Campo de busca do painel de moderação.
class FanClubModerationSearchField extends StatefulWidget {
  const FanClubModerationSearchField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<FanClubModerationSearchField> createState() =>
      _FanClubModerationSearchFieldState();
}

class _FanClubModerationSearchFieldState
    extends State<FanClubModerationSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleClear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Semantics(
      textField: true,
      label: 'Buscar no painel de moderação',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.search, size: 22, color: colors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    widget.onChanged(value);
                    setState(() {});
                  },
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Buscar pessoa ou motivo',
                    hintStyle: TextStyle(color: colors.textTertiary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  tooltip: 'Limpar busca',
                  onPressed: handleClear,
                  icon: Icon(Icons.close, size: 18, color: colors.textTertiary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
