import 'package:crowdfans/app.dart';
import 'package:crowdfans/services/cutover_flags.dart';
import 'package:crowdfans/services/env_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:crowdfans/services/push_token_service.dart';
import 'package:crowdfans/services/sentry_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.load();
  await SentryService.initialize();
  // Firebase antes do cutover: RC live precisa de [Firebase.initializeApp].
  await FirebaseService.initialize();
  await CutoverFlags.bootstrap();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: CrowdFansApp()));
}
