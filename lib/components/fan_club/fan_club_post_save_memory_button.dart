import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Atalho amarelo "Salvar Post nas Memórias" do menu de post do fã-clube.
///
/// Print CF-227: estrela 3D centralizada **acima** do rótulo (coluna), fundo
/// amarelo claro full-width — sem layout de row nem cards do menu de artista.
class FanClubPostSaveMemoryButton extends StatelessWidget {
  const FanClubPostSaveMemoryButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  /// Amarelo do print (#FFFFC1) — mais saturado que [AppPalette.orange50].
  static const Color _printYellow = Color(0xFFFFFEC1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _printYellow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 112),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/star-memory.png',
                  width: 44,
                  height: 44,
                  errorBuilder: _starFallback,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Salvar Post nas Memórias',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.orange700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _starFallback(
  BuildContext context,
  Object error,
  StackTrace? stackTrace,
) {
  return const Icon(
    Icons.star_rounded,
    size: 44,
    color: AppPalette.yellow500,
  );
}
