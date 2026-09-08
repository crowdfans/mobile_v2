import 'package:flutter/material.dart';

/// Conteúdo de um slide do onboarding.
class PresentationSlideData {
  const PresentationSlideData({
    required this.title,
    required this.accent,
    required this.subtitle,
  });

  final String title;
  final String accent;
  final String subtitle;
}

const presentationSlides = [
  PresentationSlideData(
    title: 'A música mudou.',
    accent: 'A forma de ser fã também',
    subtitle: 'Aqui você pode interagir nos fã clubes oficiais, ver o que teu artista tá fazendo ou até mesmo interagir com ele.',
  ),
  PresentationSlideData(
    title: 'Ser fã é bom.',
    accent: 'Ser Superfã é outro nível.',
    subtitle: 'Assina o Membership do seu artista favorito e mostra que você ama ele. Não tem jeito melhor de apoiar.',
  ),
  PresentationSlideData(
    title: 'Não precisa viralizar pra viver de música.',
    accent: 'Só precisa de fãs de verdade.',
    subtitle: 'Aqui você constrói sua base de fãs fiéis e recebe apoio de quem realmente te ama e te escuta.',
  ),
];

/// Título + subtítulo de um slide da presentation.
class PresentationSlide extends StatelessWidget {
  const PresentationSlide({
    super.key,
    required this.data,
    required this.textColor,
  });

  final PresentationSlideData data;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CROWD FANS',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.title,
          style: TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          data.accent,
          style: TextStyle(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Text(data.subtitle, style: TextStyle(color: textColor, fontSize: 18)),
      ],
    );
  }
}
