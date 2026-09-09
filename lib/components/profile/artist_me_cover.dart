import 'package:flutter/material.dart';

/// Cover do Meu Perfil Artista (print CF-113 / `18.35.08 (10)`).
class ArtistMeCover extends StatelessWidget {
  const ArtistMeCover({
    super.key,
    required this.imageUrl,
    required this.displayName,
    required this.membersLabel,
    required this.onEditProfile,
    required this.onJams,
    required this.onSettings,
    this.rank,
  });

  final String imageUrl;
  final String displayName;
  final String membersLabel;
  final int? rank;
  final VoidCallback onEditProfile;
  final VoidCallback onJams;
  final VoidCallback onSettings;

  static String formatMembers(int? count) {
    if (count == null) {
      return 'Sem membros ainda';
    }
    if (count >= 1000000) {
      final value = count / 1000000;
      return '${value.toStringAsFixed(1).replaceAll('.', ',')} mi membros';
    }
    if (count >= 1000) {
      final value = count / 1000;
      return '${value.toStringAsFixed(1).replaceAll('.', ',')} mil membros';
    }
    return '$count membros';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final url = imageUrl.trim();
    return SizedBox(
      height: 320 + topInset,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isEmpty)
            const ColoredBox(color: Color(0xFF1C1C1E))
          else
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: Color(0xFF1C1C1E)),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0xCC000000),
                ],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          Positioned(
            top: topInset + 8,
            right: 12,
            child: Row(
              children: [
                Material(
                  color: const Color(0xE6F5C451),
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    key: const Key('artist-me-jams'),
                    onTap: onJams,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/jam-coin.png',
                            width: 18,
                            height: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Jams',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: const Color(0x66000000),
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const Key('artist-me-settings'),
                    onTap: onSettings,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.settings, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (rank != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$rank',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  membersLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      key: const Key('artist-me-edit'),
                      onTap: onEditProfile,
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Editar Perfil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
