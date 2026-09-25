import 'package:crowdfans/components/profile/notification_category_nav_row.dart';
import 'package:crowdfans/components/profile/notification_preference_section.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notification_preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-166: hub com gerais e categorias detalhadas', (tester) async {
    final general = notificationPreferenceGroups.firstWhere(
      (group) => group.id == 'general',
    );
    final preferences = Map<String, bool>.from(notificationPreferenceDefaults);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotificationPreferenceSection(
                  group: general,
                  preferences: preferences,
                  saving: false,
                  onChanged: (_, __) {},
                ),
                const Text('Categorias detalhadas'),
                const Text(
                  'Organizamos os controles em páginas separadas para você ajustar melhor o que quer receber e de quais artistas.',
                ),
                for (final group in notificationCategoryGroups)
                  NotificationCategoryNavRow(
                    title: group.title,
                    subtitle: group.navSubtitle!,
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Preferências Gerais'), findsOneWidget);
    expect(find.text('Notificações push'), findsOneWidget);
    expect(find.text('Categorias detalhadas'), findsOneWidget);
    expect(find.text('Interações com você'), findsOneWidget);
    expect(find.text('Artistas, Cartas e Fã Clubes'), findsOneWidget);
    expect(find.text('Meet & Greet'), findsOneWidget);
    expect(find.text('Membership e Jam Coins'), findsOneWidget);
    expect(find.byType(NotificationCategoryNavRow), findsNWidgets(4));
    // Controles de interações não ficam no hub.
    expect(find.text('Curtidas em comentários'), findsNothing);
    expect(
      find.text('Curtidas do artista, respostas, menções e novos seguidores.'),
      findsOneWidget,
    );
  });
}
