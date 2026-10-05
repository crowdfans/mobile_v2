/// Conteúdo oficial estático da Central de ajuda (CF-198).
///
/// Sem CMS/API de ajuda no server-prod — copy de produto versionado no app.
/// Substitui o TEMP [Cf198HelpFixtures] / [CfTempMocks.useHelpFixtures].

/// Item de acesso rápido da Ajuda.
typedef HelpQuickAccessItem = ({
  String title,
  String subtitle,
  String destination,
});

/// Seção FAQ (perguntas já abertas — sem accordion).
typedef HelpFaqSectionData = ({String title, List<(String, String)> items});

/// Fonte oficial do texto da tela Ajuda.
abstract final class HelpContent {
  static const headerTitle = 'Ajuda';
  static const heroTitle = 'Central de ajuda';
  static const intro =
      'Reunimos aqui as respostas mais importantes do produto atual, com foco em conta, memberships, artistas, moderação, notificações e segurança.';
  static const quickAccessSectionTitle = 'Acessos rápidos';
  static const supportLabel = 'Falar com o suporte';
  static const supportSemantics = 'Falar com o suporte por e-mail';
  static const supportEmail = 'mailto:support@crowdfans.app';
  static const emptyMessage = 'Nenhum conteúdo de ajuda disponível.';

  /// Quatro acessos rápidos (título + subtítulo + destino lógico).
  static List<HelpQuickAccessItem> quickAccess() {
    return const [
      (
        title: 'Segurança e Login',
        subtitle:
            'Troca de senha, e-mail, telefone e dispositivos conectados.',
        destination: 'profileSecurity',
      ),
      (
        title: 'Meus Memberships',
        subtitle: 'Ver status, gerenciar e revisar suas assinaturas.',
        destination: 'profileMemberships',
      ),
      (
        title: 'Termos de Uso',
        subtitle: 'Regras gerais de participação e uso da plataforma.',
        destination: 'profileInformationTerms',
      ),
      (
        title: 'Política de Privacidade',
        subtitle: 'Como usamos dados de cadastro, segurança e interação.',
        destination: 'profileInformationPrivacy',
      ),
    ];
  }

  /// Seções FAQ; primeira ("Conta e perfil") já expandida na referência.
  static List<HelpFaqSectionData> faqSections() {
    return const [
      (
        title: 'Conta e perfil',
        items: [
          (
            'Como crio uma conta de fã?',
            'O cadastro é guiado em etapas dentro do app. Hoje a jornada passa por nome, username, e-mail, senha, foto de perfil, aceite dos termos e validação por OTP. Conexões sociais podem aparecer na interface, mas a disponibilidade real depende da configuração ativa do serviço.',
          ),
          (
            'Como funciona a entrada de artistas?',
            'Perfis de artistas podem existir antes da entrada oficial. A jornada de artista exige dados cadastrais adicionais e revisão quando aplicável. O app só confirma a identidade oficial quando o backend valida o perfil.',
          ),
          (
            'Como altero meus dados?',
            'Em Seu perfil você atualiza nome, username, bio e foto. Senha, e-mail, telefone e dispositivos ficam em Segurança e Login.',
          ),
        ],
      ),
      (
        title: 'Memberships e Jam Coins',
        items: [
          (
            'Onde acompanho memberships e Fan Score?',
            'Memberships e Fan Score ficam nas configurações e usam os dados retornados pela API do seu perfil. Status, pausa e cancelamento só mudam após confirmação do backend.',
          ),
          (
            'Como recarrego Jam Coins?',
            'Abra a Carteira, escolha um valor, conclua o pagamento e aguarde a confirmação. O saldo só aumenta depois que o crédito é confirmado.',
          ),
        ],
      ),
      (
        title: 'Comunidades e moderação',
        items: [
          (
            'Como funciona a moderação do fã-clube?',
            'Donos e moderadores podem registrar avisos, expulsões e revisar contestações. Cada ação mostra motivo e consequência antes da confirmação.',
          ),
          (
            'Fui expulso. Posso voltar?',
            'Quando disponível, use Defender meu retorno no Sobre do fã-clube. A moderação analisa a defesa na fila de Contestações.',
          ),
        ],
      ),
      (
        title: 'Notificações e suporte',
        items: [
          (
            'Como controlo notificações?',
            'Em Notificações você ajusta categorias como artistas, interações, Meet & Greet e memberships. Preferências são salvas no perfil.',
          ),
          (
            'Uma função aparece indisponível. Por quê?',
            'Recursos que dependem do backend ou ainda não estão liberados ficam identificados. Nenhuma ação fictícia é apresentada como concluída.',
          ),
        ],
      ),
    ];
  }
}
