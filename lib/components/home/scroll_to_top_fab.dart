import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// FAB circular “voltar ao topo” do feed Home (prints CF-67).
class ScrollToTopFab extends StatelessWidget {
  const ScrollToTopFab({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 18, bottom: 18),
            child: Material(
              color: colors.surface,
              elevation: 3,
              shadowColor: Colors.black26,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox(
                  width: 58,
                  height: 58,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 28,
                    color: colors.textSecondary,
                    semanticLabel: 'Voltar ao topo',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
