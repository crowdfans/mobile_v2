import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Seção das diretrizes estáticas do fã clube.
class FanClubRulesSection {
  const FanClubRulesSection({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}

/// Conteúdo portado do Expo (`FanClubRulesScreen`).
const fanClubRulesSections = <FanClubRulesSection>[
  FanClubRulesSection(
    id: 'respect',
    title: '1. Respeito sempre, em qualquer lugar da plataforma',
    body: 'Toda comunidade boa começa pelo respeito. Aqui, isso vale para artistas, fãs, equipe, moderação e qualquer pessoa que faça parte da plataforma. Insultos, humilhações, ameaças, assédio, preconceito, discurso de ódio ou qualquer forma de agressão não combinam com a Crowd Fans. Você pode discordar, conversar e até pensar diferente. O que não cabe aqui é transformar troca em ataque.',
  ),
  FanClubRulesSection(
    id: 'spaces',
    title: '2. Cada espaço tem sua vibe: entenda como funciona',
    body: 'Cada espaço dentro da Crowd Fans foi pensado para um tipo de conexão. No Feed do Artista, quem publica é o artista, e os fãs entram para acompanhar, reagir, comentar e viver as experiências propostas ali. Já nas Comunidades, os fãs ganham voz para abrir conversas, compartilhar ideias, trocar vivências e conhecer outras pessoas na mesma sintonia. É um espaço mais aberto, mas não sem cuidado. Flood, provocação gratuita, desinformação e conteúdo criado apenas para gerar atrito vão contra o espírito da comunidade.',
  ),
  FanClubRulesSection(
    id: 'offensive-content',
    title: '3. Conteúdo ofensivo ou ilegal não tem vez',
    body: 'A gente acredita em expressão, troca e liberdade para participar. Mas isso não inclui material nocivo ou ilegal. Conteúdos com pornografia, nudez explícita, incentivo à violência, apologia a crimes, discriminação ou qualquer manifestação de intolerância podem ser removidos imediatamente. Em situações mais graves, a conta responsável também pode sofrer restrições sem aviso prévio.',
  ),
  FanClubRulesSection(
    id: 'privacy',
    title: '4. Privacidade é coisa séria',
    body: 'Informações pessoais pedem cuidado de verdade. Não publique endereço, telefone, documentos, localização em tempo real, imagens íntimas ou qualquer outro dado sensível, seu ou de terceiros. Também não exponha conversas privadas nem compartilhe dados de outras pessoas sem consentimento. E, para sua segurança, a Crowd Fans nunca solicita senha, cartão ou dados bancários por mensagem ou e-mail.',
  ),
  FanClubRulesSection(
    id: 'spam',
    title: '5. Sem spam, sem flood, sem autopromoção forçada',
    body: 'Quando alguém insiste no mesmo conteúdo, repete mensagens ou tenta ocupar todos os espaços com autopromoção, a experiência da comunidade perde força. A ideia aqui é conversa real, não barulho. O fã clube não é espaço para ficar divulgando música própria, projeto pessoal, link, perfil ou qualquer conteúdo postado só para se promover. Se algo seu fizer sentido dentro da conversa, isso precisa acontecer com contexto, bom senso e respeito pelo momento, sem transformar cada post em vitrine.',
  ),
  FanClubRulesSection(
    id: 'reports',
    title: '6. Denunciar é um ato de cuidado, use com responsabilidade',
    body: 'Se alguma situação passar do limite, denuncie. O recurso de denúncia existe para ajudar a proteger a comunidade e orientar a moderação. Ao mesmo tempo, ele não foi criado para perseguir pessoas, calar opiniões diferentes ou alimentar rivalidades. Usar essa ferramenta com responsabilidade também é uma forma de cuidado.',
  ),
  FanClubRulesSection(
    id: 'good-energy',
    title: '7. Mantenha a energia boa',
    body: 'A Crowd Fans nasceu para aproximar pessoas por meio da música. A gente quer um ambiente de descoberta, apoio, entusiasmo e troca verdadeira. Quanto mais respeito, abertura e vontade de somar aparecerem nas interações, melhor a experiência para todo mundo. No fim, o que faz a comunidade valer a pena é isso: presença real, energia boa e conexão de verdade.',
  ),
];

/// Bloco visual de uma diretriz.
class FanClubRulesSectionView extends StatelessWidget {
  const FanClubRulesSectionView({
    super.key,
    required this.section,
    this.showDivider = true,
  });

  final FanClubRulesSection section;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: colors.textSecondary,
            ),
          ),
          if (showDivider) ...[
            const SizedBox(height: 22),
            Divider(height: 1, color: colors.border),
          ],
        ],
      ),
    );
  }
}
