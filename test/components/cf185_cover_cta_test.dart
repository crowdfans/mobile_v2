import 'package:crowdfans/components/profile/artist_profile_cover_cta.dart';
import 'package:crowdfans/components/profile/artist_profile_public_cover.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CF-185: cover mostra + Seguir quando não segue', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: '',
            displayName: 'Ludmilla',
            membersLabel: '512,0 mil membros',
            following: false,
            subscribed: false,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
            onMembership: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('+ Seguir'), findsOneWidget);
    expect(find.textContaining('Membership'), findsNothing);
  });

  testWidgets('CF-185: cover Membership ♪ quando segue sem assinatura', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfileCoverCta(
            kind: ArtistProfileCoverCtaKind.membershipSubscribe,
            busy: false,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Membership'), findsOneWidget);
    expect(find.text('+ Seguir'), findsNothing);
  });

  testWidgets('CF-185: cover Membership ✓ quando assinante', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildCrowdFansTheme(Brightness.light),
        home: Scaffold(
          body: ArtistProfilePublicCover(
            imageUrl: '',
            displayName: 'Mayra',
            membersLabel: '368,0 mil membros',
            following: true,
            subscribed: true,
            busy: false,
            onBack: () {},
            onMore: () {},
            onToggleFollow: () {},
            onMembership: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Membership'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('+ Seguir'), findsNothing);
  });
}
