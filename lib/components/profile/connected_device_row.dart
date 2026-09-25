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
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              session.isPhone ? Icons.smartphone_outlined : Icons.laptop_mac,
              size: 22,
              color: colors.textPrimary,
            ),
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
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Este dispositivo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                const SizedBox(height: 2),
                Text(
                  session.activity,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onDisconnect != null)
            TextButton(
              onPressed: onDisconnect,
              style: TextButton.styleFrom(
                foregroundColor: colors.danger,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Desconectar',
                style: TextStyle(
                  color: colors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
