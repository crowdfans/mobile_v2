import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Bottom sheet com overlay (fade) e painel deslizando de baixo.
class BottomSheetShell extends StatefulWidget {
  const BottomSheetShell({
    super.key,
    required this.visible,
    required this.onClose,
    required this.child,
  });

  final bool visible;
  final VoidCallback onClose;
  final Widget child;

  @override
  State<BottomSheetShell> createState() => _BottomSheetShellState();
}

class _BottomSheetShellState extends State<BottomSheetShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _shouldRender = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 280),
    );
    if (widget.visible) {
      _shouldRender = true;
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(BottomSheetShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      setState(() => _shouldRender = true);
      _controller.forward(from: 0);
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse().whenComplete(() {
        if (mounted) {
          setState(() => _shouldRender = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldRender) {
      return const SizedBox.shrink();
    }
    final colors = CrowdFansTheme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    return Positioned.fill(
      child: Stack(
        children: [
          FadeTransition(
            opacity: fade,
            child: GestureDetector(
              onTap: widget.onClose,
              child: const ColoredBox(color: Color(0x73000000)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: slide,
              child: Material(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    bottom < 24 ? 24 : bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      widget.child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
