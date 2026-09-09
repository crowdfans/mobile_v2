import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Seção de um documento legal (termos / privacidade).
class InformationDocumentSection {
  const InformationDocumentSection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
}

/// Texto de termos / privacidade com título e seções.
class InformationDocumentView extends StatelessWidget {
  const InformationDocumentView({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String intro;
  final List<InformationDocumentSection> sections;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          intro,
          style: TextStyle(
            fontSize: 14,
            height: 1.55,
            color: colors.textSecondary,
          ),
        ),
        for (final section in sections) ...[
          const SizedBox(height: 20),
          Text(
            section.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          for (final paragraph in section.paragraphs) ...[
            const SizedBox(height: 8),
            Text(
              paragraph,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Text(
          'Última atualização: 3 de agosto de 2026.',
          style: TextStyle(fontSize: 13, color: colors.textTertiary),
        ),
      ],
    );
  }
}

/// Card de pergunta frequente na aba Ajuda.
class InformationHelpCard extends StatelessWidget {
  const InformationHelpCard({
    super.key,
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo dos Termos de Uso (espelho do Expo).
const informationTermsSections = [
  InformationDocumentSection(
    title: '1. Aceitação e conta',
    paragraphs: [
      'Ao criar uma conta ou usar a CrowdFans, você concorda com estes Termos de Uso. Forneça informações verdadeiras, mantenha suas credenciais protegidas e use os mecanismos de segurança quando identificar atividade incomum.',
      'Perfis de fã e de artista possuem papéis diferentes. A identidade oficial de artista e os dados protegidos da conta não podem ser usados para impersonação ou fraude.',
    ],
  ),
  InformationDocumentSection(
    title: '2. Conteúdo e comunidades',
    paragraphs: [
      'Você continua responsável por posts, comentários, Fan Letters, imagens, vídeos e demais materiais que publicar. Ao enviar conteúdo, concede a licença necessária para que a plataforma o hospede e exiba dentro dos seus recursos.',
      'Não são permitidos assédio, ameaças, discurso de ódio, golpes, spam, exposição de dados pessoais, conteúdo ilegal, violência gráfica, material sexual explícito ou violação de direitos de terceiros.',
    ],
  ),
  InformationDocumentSection(
    title: '3. Memberships e experiências',
    paragraphs: [
      'Memberships representam apoio recorrente a artistas. Conteúdos exclusivos, lives, Meet & Greet e outros benefícios dependem da disponibilidade de cada experiência e não constituem promessa de frequência fixa ou resposta pessoal do artista.',
      'Operações com Jam Coins, renovações e pagamentos dependem dos serviços financeiros ativos e das regras mostradas antes da confirmação de cada operação.',
    ],
  ),
  InformationDocumentSection(
    title: '4. Moderação e disponibilidade',
    paragraphs: [
      'A CrowdFans pode remover conteúdo, limitar acessos ou suspender contas em casos de abuso, fraude ou risco ao ecossistema. Contestações podem ser oferecidas quando aplicável.',
      'Funcionalidades podem evoluir, mudar ou depender de integrações externas. A versão vigente destes termos pode ser atualizada para refletir mudanças do produto ou obrigações legais.',
    ],
  ),
];

/// Conteúdo da Política de Privacidade (espelho do Expo).
const informationPrivacySections = [
  InformationDocumentSection(
    title: '1. Dados tratados',
    paragraphs: [
      'A CrowdFans pode tratar nome, username, e-mail, telefone, foto, dados de autenticação, preferências, artistas seguidos, memberships, interações e conteúdos publicados.',
      'Também podem ser registrados dados técnicos de sessão, segurança, dispositivo e uso necessários para operar o aplicativo, prevenir fraude e investigar incidentes.',
    ],
  ),
  InformationDocumentSection(
    title: '2. Finalidades',
    paragraphs: [
      'Os dados são usados para criar e proteger sua conta, personalizar a experiência, operar comunidades e recursos sociais, processar funcionalidades contratadas, entregar notificações e prestar suporte.',
      'Quando uma operação exigir câmera, galeria ou outra permissão do aparelho, o aplicativo solicitará sua autorização antes do acesso.',
    ],
  ),
  InformationDocumentSection(
    title: '3. Compartilhamento e retenção',
    paragraphs: [
      'Informações podem ser processadas por provedores de autenticação, infraestrutura, armazenamento, notificações, pagamentos e segurança na medida necessária para executar o serviço.',
      'Os dados são mantidos pelo período necessário para operação, segurança, cumprimento de obrigações e defesa de direitos. Depois disso, podem ser excluídos ou anonimizados.',
    ],
  ),
  InformationDocumentSection(
    title: '4. Seus direitos',
    paragraphs: [
      'Você pode solicitar acesso, correção e esclarecimentos sobre seus dados e, quando aplicável, exclusão, oposição ou limitação do tratamento. Pedidos sensíveis podem exigir verificação adicional de identidade.',
    ],
  ),
];
