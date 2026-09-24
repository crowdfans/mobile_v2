import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_badge.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_card.dart';
import 'package:crowdfans/components/profile/membership_activation_confirmed_info_note.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/screens/profile/profile_membership_activation_confirmed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-207: confirmação vincula artista e preço reais; Fechar → memberships',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: const ProfileMembershipActivationConfirmedScreen(
            artistName: 'Banda Uelo',
            artistHandle: 'bandauelo',
            pricePerMonth: 100,
            artistId: 'artist-1',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Membership ativo'), findsOneWidget);
      expect(find.text('Oficialmente do bando!'), findsOneWidget);
      expect(find.textContaining('Banda Uelo'), findsWidgets);
      expect(find.text('@bandauelo'), findsOneWidget);
      expect(find.text('100 /mês'), findsOneWidget);
      expect(find.text('240 /mês'), findsNothing);
      expect(find.byType(MembershipActivationConfirmedBadge), findsOneWidget);
      expect(find.byType(MembershipActivationConfirmedCard), findsOneWidget);
      expect(find.byType(MembershipActivationConfirmedInfoNote), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);
      expect(Pages.profileMemberships, '/me/settings/memberships');
      expect(
        Pages.profileMembershipActivationConfirmedOf(
          artistName: 'Banda Uelo',
          pricePerMonth: 100,
        ),
        contains('pricePerMonth=100'),
      );
      expect(find.byType(AppButton), findsOneWidget);
    },
  );
}
