import 'package:flutter/material.dart';

/// Toolbar grudada no topo do scroll (espelho do `StickyToolbarComponent`).
class StickyToolbar extends StatelessWidget {
  const StickyToolbar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyToolbarDelegate(child: child),
    );
  }
}

class _StickyToolbarDelegate extends SliverPersistentHeaderDelegate {
  _StickyToolbarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyToolbarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
