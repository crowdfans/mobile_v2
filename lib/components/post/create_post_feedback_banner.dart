import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Banner de erro ou sucesso no formulário de criar post.
class CreatePostFeedbackBanner extends StatelessWidget {
  const CreatePostFeedbackBanner({
    super.key,
    required this.message,
    required this.success,
  });

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: success ? AppPalette.green700 : colors.danger,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 14, color: colors.background),
      ),
    );
  }
}
