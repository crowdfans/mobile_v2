import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/report_service.dart';
import 'package:flutter/material.dart';

/// Linha de motivo na primeira etapa da denúncia.
class ReportReasonRow extends StatelessWidget {
  const ReportReasonRow({
    super.key,
    required this.option,
    required this.onPressed,
  });

  final ReportReasonOption option;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: colors.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.helper,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
