import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrowdFansApp extends ConsumerWidget {
  const CrowdFansApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'CrowdFans',
      debugShowCheckedModeBanner: false,
      theme: buildCrowdFansTheme(Brightness.light),
      darkTheme: buildCrowdFansTheme(Brightness.dark),
      routerConfig: router,
    );
  }
}
