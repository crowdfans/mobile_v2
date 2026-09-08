import 'package:crowdfans/components/navigation/bottom_nav_profile_tab.dart';
import 'package:crowdfans/components/navigation/bottom_nav_svg_tab.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/state/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom nav das 4 abas + atalho de criar (SVGs do Expo).
class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.navigationShell,
    this.onPressPlus,
  });

  final StatefulNavigationShell navigationShell;
  final VoidCallback? onPressPlus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = CrowdFansTheme.of(context);
    final photoUrl = ref.watch(authSessionProvider).profile?.photoUrl;
    final index = navigationShell.currentIndex;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BottomNavSvgTab(
                asset: 'assets/special-icons/home-menu-01.svg',
                selected: index == 0,
                semanticLabel: 'Ir para o início',
                onTap: () => navigationShell.goBranch(0),
              ),
              BottomNavSvgTab(
                asset: 'assets/special-icons/community-01.svg',
                selected: index == 1,
                semanticLabel: 'Fan clubs',
                onTap: () => navigationShell.goBranch(1),
              ),
              BottomNavSvgTab(
                asset: 'assets/icons/General/plus-square.svg',
                selected: false,
                showIndicator: false,
                semanticLabel: 'Criar conteúdo',
                onTap:
                    onPressPlus ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Criar post / fan club entra no próximo corte.',
                          ),
                        ),
                      );
                    },
              ),
              BottomNavSvgTab(
                asset: 'assets/special-icons/search-menu-01.svg',
                selected: index == 2,
                semanticLabel: 'Buscar',
                onTap: () => navigationShell.goBranch(2),
              ),
              BottomNavProfileTab(
                selected: index == 3,
                photoUrl: photoUrl,
                onTap: () => navigationShell.goBranch(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
