import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Texto de alinhamento de expectativas antes de assinar (CF-206).
class MembershipSubscribeExpectations extends StatelessWidget {
  const MembershipSubscribeExpectations({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Antes de confirmar sua assinatura...',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Antes de seguir para o pagamento, queremos alinhar as expectativas para que sua experiência seja a melhor possível:',
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: colors.textPrimary,
            ),
            children: const [
              TextSpan(
                text: 'Apoio em primeiro lugar: ',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text:
                    'Ao assinar, seu principal papel é o de patrono. Seu valor mensal é um incentivo direto para que o artista continue criando e mantendo sua estrutura independente.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: colors.textPrimary,
            ),
            children: const [
              TextSpan(
                text: 'Conteúdo e Interação: ',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text:
                    'Embora o artista se esforce para trazer mimos e conteúdos extras, a assinatura não garante uma frequência fixa de postagens exclusivas, lives ou meet & greets.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
