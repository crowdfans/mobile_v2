import 'package:crowdfans/app.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.example');
  await FirebaseService.initialize();
  runApp(const ProviderScope(child: CrowdFansApp()));
}
