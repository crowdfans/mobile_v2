import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Formata segundos restantes (mm:ss).
String formatMeetCountdown(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final m = (safe ~/ 60).toString().padLeft(2, '0');
  final s = (safe % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Fundo escuro padrão das telas Meet.
class MeetScreenFrame extends StatelessWidget {
  const MeetScreenFrame({
    super.key,
    required this.child,
    this.imageUrl,
  });

  final Widget child;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    return Scaffold(
      backgroundColor: AppPalette.platinum950,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isNotEmpty)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppPalette.platinum950,
              ),
            )
          else
            const ColoredBox(color: AppPalette.platinum950),
          const ColoredBox(color: Color(0xCC0F172A)),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

/// Botão circular de ação (aceitar / recusar / encerrar).
class MeetRoundActionButton extends StatelessWidget {
  const MeetRoundActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.label,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 68,
              height: 68,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        ),
        if ((label ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ],
    );
  }
}

/// Avatar + nome no topo das telas de ringing/waiting.
class MeetPeerHeader extends StatelessWidget {
  const MeetPeerHeader({
    super.key,
    required this.name,
    this.imageUrl,
    this.subtitle,
  });

  final String name;
  final String? imageUrl;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppPalette.platinum700,
          backgroundImage: url.isEmpty ? null : NetworkImage(url),
          child: url.isEmpty
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          name.isEmpty ? 'Meet & Greet' : name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        if ((subtitle ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
