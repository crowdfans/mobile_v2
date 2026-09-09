import 'package:flutter/material.dart';

/// Botão circular de ferramenta do compose (mock Superfã).
class FanLetterToolButton extends StatelessWidget {
  const FanLetterToolButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool active;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ??
        (active ? const Color(0xFFA285FF) : const Color(0xFF1E293B));
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
