import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Atalho amarelo "Salvar Post nas Memórias" do menu de post do fã-clube.
class FanClubPostSaveMemoryButton extends StatelessWidget {
  const FanClubPostSaveMemoryButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.orange50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/star-memory.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.star_rounded,
                    size: 36,
                    color: AppPalette.yellow500,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Salvar Post nas Memórias',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.orange700,
                    ),
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
