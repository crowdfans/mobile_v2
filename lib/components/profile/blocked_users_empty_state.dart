import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:flutter/material.dart';

/// Estado vazio da lista de usuários bloqueados (CF-161).
///
/// Referência LEFT: título/descrição à esquerda e bloco no meio vertical
/// da área de conteúdo (não centralizado horizontalmente).
class BlockedUsersEmptyState extends StatelessWidget {
  const BlockedUsersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: ProfileState(
        title: 'Nenhum usuário bloqueado',
        message:
            'Quando você bloquear alguém, o perfil aparecerá aqui para desbloqueio.',
        align: TextAlign.left,
      ),
    );
  }
}
