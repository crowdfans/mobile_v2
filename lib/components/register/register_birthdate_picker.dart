import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Spinner iOS / botão Android para a data de nascimento.
class RegisterBirthdatePicker extends StatelessWidget {
  const RegisterBirthdatePicker({
    super.key,
    required this.value,
    required this.maxDate,
    required this.onChanged,
  });

  final DateTime value;
  final DateTime maxDate;
  final ValueChanged<DateTime> onChanged;

  Future<void> handleOpenAndroidPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value.isAfter(maxDate) ? maxDate : value,
      firstDate: DateTime(1920),
      lastDate: maxDate,
    );
    if (picked == null) {
      return;
    }
    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIos) {
      return SizedBox(
        height: 220,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: value.isAfter(maxDate) ? maxDate : value,
          maximumDate: maxDate,
          minimumDate: DateTime(1920),
          onDateTimeChanged: onChanged,
        ),
      );
    }

    final label =
        '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => handleOpenAndroidPicker(context),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          backgroundColor: colors.inputBackground,
          side: BorderSide(color: colors.inputBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Selecionar data',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
