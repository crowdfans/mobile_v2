import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Toggle Exclusivo no formulário de post da Home.
class CreatePostExclusiveToggle extends StatelessWidget {
  const CreatePostExclusiveToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        'Exclusivo',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
      subtitle: Text(
        'Só membros do membership veem este post.',
        style: TextStyle(fontSize: 13, color: colors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: colors.primary,
    );
  }
}
