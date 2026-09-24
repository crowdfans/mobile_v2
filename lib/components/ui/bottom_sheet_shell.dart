import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Bottom sheet com painel em *slide up* (sem fade de opacidade).
///
/// Por padrão usa o [Overlay] raiz para ficar **acima** da bottom nav.
/// O menu (+) ([coverNavigation] = false) continua no Stack do shell, sob a nav.
class BottomSheetShell extends StatefulWidget {
  const BottomSheetShell({
    super.key,
    required this.visible,
    required this.onClose,
    required this.child,
    this.bottomOffset = 0,
    this.coverNavigation = true,
  });

  final bool visible;
  final VoidCallback onClose;
  final Widget child;

  /// Espaço extra abaixo do painel (ex.: altura da bottom nav quando ela
  /// permanece acima do sheet).
  final double bottomOffset;

  /// Se true, desenha no overlay raiz por cima da Navigation Bar.
  final bool coverNavigation;

  @override
  State<BottomSheetShell> createState() => _BottomSheetShellState();
}

class _BottomSheetShellState extends State<BottomSheetShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _shouldRender = false;
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _controller.addListener(_onTick);
    if (widget.visible) {
      _shouldRender = true;
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
    }
  }

  void _onTick() {
    _entry?.markNeedsBuild();
    if (mounted && !widget.coverNavigation) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(BottomSheetShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      setState(() => _shouldRender = true);
      _controller.forward(from: 0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
    } else if (!widget.visible && oldWidget.visible) {
      _controller.reverse().whenComplete(() {
        if (!mounted) {
          return;
        }
        setState(() => _shouldRender = false);
        _removeOverlay();
      });
    } else if (widget.coverNavigation != oldWidget.coverNavigation ||
        widget.child != oldWidget.child ||
        widget.bottomOffset != oldWidget.bottomOffset) {
      _entry?.markNeedsBuild();
      _syncOverlay();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _syncOverlay() {
    if (!mounted || !widget.coverNavigation) {
      if (!widget.coverNavigation) {
        _removeOverlay();
      }
      return;
    }
    if (!_shouldRender) {
      _removeOverlay();
      return;
    }
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    if (_entry == null) {
      _entry = OverlayEntry(builder: (context) => _buildSheet(context));
      overlay.insert(_entry!);
    } else {
      _entry!.markNeedsBuild();
    }
  }

  Widget _buildSheet(BuildContext hostContext) {
    final colors = CrowdFansTheme.of(this.context);
    final bottom = MediaQuery.paddingOf(hostContext).bottom;
    final slide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onClose,
            child: const ColoredBox(color: Color(0x73000000)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: slide,
            child: GestureDetector(
              onTap: () {},
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
                    (bottom < 24 ? 24 : bottom) + widget.bottomOffset,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.coverNavigation) {
      // Conteúdo vai no Overlay raiz (acima da bottom nav).
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncOverlay());
      return const SizedBox.shrink();
    }
    if (!_shouldRender) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(child: _buildSheet(context));
  }
}
