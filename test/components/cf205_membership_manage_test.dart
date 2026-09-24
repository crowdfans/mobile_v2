import 'package:crowdfans/components/profile/membership_manage_option_tile.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CF-205: selecionar opção não confirma; Pausar e Cancelar separados',
    (tester) async {
      var selected = MembershipManageAction.pause;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCrowdFansTheme(Brightness.light),
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    MembershipManageOptionTile(
                      action: MembershipManageAction.pause,
                      selected: selected == MembershipManageAction.pause,
                      onSelected: (action) => setState(() => selected = action),
                    ),
                    MembershipManageOptionTile(
                      action: MembershipManageAction.cancel,
                      selected: selected == MembershipManageAction.cancel,
                      onSelected: (action) => setState(() => selected = action),
                    ),
                    Text('selecionado: ${selected.name}'),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Pausar membership'), findsOneWidget);
      expect(find.text('Cancelar membership'), findsOneWidget);
      expect(find.textContaining('interrompe a cobrança'), findsOneWidget);
      expect(find.textContaining('encerra a assinatura'), findsOneWidget);
      expect(find.text('selecionado: pause'), findsOneWidget);

      await tester.tap(find.text('Cancelar membership'));
      await tester.pump();

      expect(find.text('selecionado: cancel'), findsOneWidget);
    },
  );
}
