import 'package:crowdfans/app.dart';
import 'package:crowdfans/services/env_service.dart';
import 'package:crowdfans/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patrol/patrol.dart';

/// Bootstrap do app para Patrol (CF-123).
///
/// Diferenças vs `main.dart`:
/// - sem `WidgetsFlutterBinding.ensureInitialized()` / `runApp`
/// - sem Sentry (evita interceptar `FlutterError.onError`)
/// - sem handler de push em background
/// - encerra sessão Firebase para smoke deslogado
Future<void> bootstrapCrowdFansForPatrol(PatrolIntegrationTester $) async {
  await EnvService.load();
  await FirebaseService.initialize();
  await FirebaseAuth.instance.signOut();

  await $.pumpWidget(const ProviderScope(child: CrowdFansApp()));
  // Vídeos do onboarding nunca “settlam”; espera curta basta para a 1ª frame.
  await $.pump(const Duration(milliseconds: 800));
  await $.pump(const Duration(milliseconds: 800));
}
