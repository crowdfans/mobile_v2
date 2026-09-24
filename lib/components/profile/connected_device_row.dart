import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Sessão/dispositivo conectado (CF-216).
class ConnectedDeviceSession {
  const ConnectedDeviceSession({
    required this.id,
    required this.name,
    required this.platformLine,
    required this.location,
    required this.activity,
    required this.isCurrent,
    this.isPhone = true,
  });

  final String id;
  final String name;
  final String platformLine;
  final String location;
  final String activity;
  final bool isCurrent;
  final bool isPhone;
}

/// Linha de dispositivo conectado.
class ConnectedDeviceRow extends StatelessWidget {
  const ConnectedDeviceRow({
    super.key,
    required this.session,
    this.onDisconnect,
  });

  final ConnectedDeviceSession session;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            session.isPhone ? Icons.smartphone_outlined : Icons.laptop_mac,
            size: 28,
            color: colors.textPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        session.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (session.isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppPalette.purple100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Este dispositivo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  session.platformLine,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                Text(
                  session.location,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                Text(
                  session.activity,
                  style: TextStyle(
                    fontSize: 13,
                    color: session.isCurrent
                        ? AppPalette.green700
                        : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (onDisconnect != null)
            TextButton(
              onPressed: onDisconnect,
              child: Text(
                'Desconectar',
                style: TextStyle(
                  color: colors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
