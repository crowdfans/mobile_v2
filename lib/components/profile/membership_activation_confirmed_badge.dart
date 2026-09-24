import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Badge verde "Membership ativo" (print CF-207).
class MembershipActivationConfirmedBadge extends StatelessWidget {
  const MembershipActivationConfirmedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Membership ativo',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.green50,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'Membership ativo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppPalette.green700,
            ),
          ),
        ),
      ),
    );
  }
}
