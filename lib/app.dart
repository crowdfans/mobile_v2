import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrowdFansApp extends ConsumerWidget {
  const CrowdFansApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // Produto = somente tema claro (ignora dark do sistema e preferência antiga).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppPalette.platinum50,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp.router(
        title: 'CrowdFans',
        debugShowCheckedModeBanner: false,
        theme: buildCrowdFansTheme(Brightness.light),
        themeMode: ThemeMode.light,
        routerConfig: router,
      ),
    );
  }
}
