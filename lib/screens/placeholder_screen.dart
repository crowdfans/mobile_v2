import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Tela temporária até a feature correspondente do Expo ser migrada.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
