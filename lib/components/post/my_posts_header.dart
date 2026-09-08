import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Título + botão "+ Novo" da tela Meus posts.
class MyPostsHeader extends StatelessWidget {
  const MyPostsHeader({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Meus Posts',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ),
          FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('+ Novo'),
          ),
        ],
      ),
    );
  }
}
