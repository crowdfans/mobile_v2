import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Stub do lobby do Meet & Greet Virtual (CF-152).
/// UI completa (fila/paywall) chega em CF-150.
class MeetLobbyScreen extends StatelessWidget {
  const MeetLobbyScreen({
    super.key,
    required this.eventId,
    this.artistName,
    this.avatarUrl,
  });

  final String eventId;
  final String? artistName;
  final String? avatarUrl;

  void handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final title = (artistName ?? '').trim().isEmpty
        ? 'Meet & Greet'
        : 'Meet & Greet · ${artistName!.trim()}';
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToolbarBackButton(onPressed: () => handleBack(context)),
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
                'Lobby do evento em preparação. Em breve: fila, membership e call.',
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
              ),
              if (eventId.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Evento: ${eventId.trim()}',
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
