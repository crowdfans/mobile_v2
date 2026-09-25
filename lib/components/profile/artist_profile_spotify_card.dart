import 'package:crowdfans/components/profile/artist_profile_spotify_stat_tile.dart';
import 'package:flutter/material.dart';

/// Card Spotify da aba Sobre com hierarquia do print (play / prévia / métricas).
class ArtistProfileSpotifyCard extends StatelessWidget {
  const ArtistProfileSpotifyCard({
    super.key,
    this.artistName = '',
    this.title,
    this.subtitle = 'Playlist em destaque',
    this.previewReady = false,
    this.monthlyListeners = 'Não informado',
    this.genre = 'Não informado',
    this.onOpenSpotify,
  });

  final String artistName;
  final String? title;
  final String subtitle;
  final bool previewReady;
  final String monthlyListeners;
  final String genre;
  final VoidCallback? onOpenSpotify;

  @override
  Widget build(BuildContext context) {
    final track = (title ?? '').trim();
    final hasTrack = track.isNotEmpty;
    final displayTitle = hasTrack ? track : 'Prévia Spotify';
    final name = artistName.trim().isEmpty ? 'Artista' : artistName.trim();
    return Semantics(
      label: hasTrack && previewReady
          ? 'Prévia Spotify de $displayTitle, pronta para tocar'
          : 'Prévia Spotify indisponível',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.music_note_rounded, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Spotify',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasTrack ? subtitle : 'Sem prévia no cadastro do artista',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: previewReady
                                ? const Color(0xFF1DB954)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            previewReady
                                ? 'Prévia Spotify'
                                : 'Prévia indisponível',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '0:15',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Semantics(
                            button: true,
                            enabled: previewReady,
                            label: previewReady
                                ? 'Reproduzir prévia'
                                : 'Reproduzir indisponível',
                            child: Icon(
                              Icons.play_circle_filled,
                              size: 42,
                              color: previewReady
                                  ? const Color(0xFF1DB954)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.refresh_rounded,
                            size: 22,
                            color: previewReady
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF475569),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 28,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final h in const [
                              10.0,
                              18.0,
                              14.0,
                              22.0,
                              12.0,
                              20.0,
                              16.0,
                              24.0,
                              11.0,
                              19.0,
                              15.0,
                              21.0,
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1.5,
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF64748B),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: SizedBox(height: h),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        previewReady
                            ? 'Prévia pronta para tocar'
                            : 'Prévia não disponível neste perfil',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ArtistProfileSpotifyStatTile(
                      label: 'OUVINTES MENSAIS',
                      value: monthlyListeners,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ArtistProfileSpotifyStatTile(
                      label: 'GÊNERO',
                      value: genre,
                    ),
                  ),
                ],
              ),
              if (onOpenSpotify != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onOpenSpotify,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1DB954),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Abrir no Spotify',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
