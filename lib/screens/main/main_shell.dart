import 'package:crowdfans/components/home/create_menu_sheet.dart';
import 'package:crowdfans/components/navigation/bottom_nav_bar.dart';
import 'package:crowdfans/state/create_menu_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shell autenticado: conteúdo da aba + bottom nav CrowdFans.
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCreateMenuOpen = ref.watch(createMenuProvider);
    return Stack(
      children: [
        Scaffold(
          body: navigationShell,
          bottomNavigationBar: BottomNavBar(
            navigationShell: navigationShell,
            onPressPlus: () {
              ref.read(createMenuProvider.notifier).openMenu();
            },
          ),
        ),
        CreateMenuSheet(
          visible: isCreateMenuOpen,
          onClose: () {
            ref.read(createMenuProvider.notifier).closeMenu();
          },
        ),
      ],
    );
  }
}
