import 'package:crowdfans/components/profile/help_faq_section.dart';
import 'package:crowdfans/components/profile/help_quick_access_row.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Central de ajuda — hierarquia de títulos, explicações e links.
class ProfileHelpScreen extends StatelessWidget {
  const ProfileHelpScreen({super.key});

  Future<void> handleContactSupport(BuildContext context) async {
    final uri = Uri.parse('mailto:support@crowdfans.app');
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      await AppAlert.show(
        context,
        title: 'Suporte',
        message:
            'Não foi possível abrir o e-mail. Escreva para support@crowdfans.app.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'Ajuda',
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                context.go(Pages.profileSettings);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Central de ajuda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Reunimos aqui as respostas mais importantes do produto atual, com foco em conta, memberships, artistas, moderação, notificações e segurança.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Semantics(
                    header: true,
                    child: Text(
                      'Acessos rápidos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  HelpQuickAccessRow(
                    title: 'Segurança e Login',
                    subtitle:
                        'Troca de senha, e-mail, telefone e dispositivos conectados.',
                    onTap: () => context.push(Pages.profileSecurity),
                  ),
                  HelpQuickAccessRow(
                    title: 'Meus Memberships',
                    subtitle:
                        'Ver status, gerenciar e revisar suas assinaturas.',
                    onTap: () => context.push(Pages.profileMemberships),
                  ),
                  HelpQuickAccessRow(
                    title: 'Termos de Uso',
                    subtitle:
                        'Regras gerais de participação e uso da plataforma.',
                    onTap: () => context.push(
                      '${Pages.profileInformation}?tab=terms',
                    ),
                  ),
                  HelpQuickAccessRow(
                    title: 'Política de Privacidade',
                    subtitle:
                        'Como usamos dados de cadastro, segurança e interação.',
                    onTap: () => context.push(
                      '${Pages.profileInformation}?tab=privacy',
                    ),
                    showDivider: false,
                  ),
                  const SizedBox(height: 28),
                  const HelpFaqSection(
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
                  const HelpFaqSection(
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
                  const HelpFaqSection(
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
                  const HelpFaqSection(
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
                  const SizedBox(height: 8),
                  Semantics(
                    button: true,
                    label: 'Falar com o suporte por e-mail',
                    child: TextButton(
                      onPressed: () => handleContactSupport(context),
                      child: Text(
                        'Falar com o suporte',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
