import 'package:crowdfans/app.dart';
import 'package:crowdfans/services/env_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/sentry_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.load();
  await SentryService.initialize();
  await FirebaseService.initialize();
  runApp(const ProviderScope(child: CrowdFansApp()));
}
