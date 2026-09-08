import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CrowdFansApp extends ConsumerWidget {
  const CrowdFansApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final textTheme = GoogleFonts.interTextTheme();
    return MaterialApp.router(
      title: 'CrowdFans',
      debugShowCheckedModeBanner: false,
      theme: buildCrowdFansTheme(Brightness.light).copyWith(textTheme: textTheme),
      darkTheme:
          buildCrowdFansTheme(Brightness.dark).copyWith(textTheme: textTheme),
      routerConfig: router,
    );
  }
}
