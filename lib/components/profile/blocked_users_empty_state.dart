import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:flutter/material.dart';

/// Estado vazio da lista de usuários bloqueados (CF-161).
class BlockedUsersEmptyState extends StatelessWidget {
  const BlockedUsersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileState(
      title: 'Nenhum usuário bloqueado',
      message:
          'Quando você bloquear alguém, o perfil aparecerá aqui para desbloqueio.',
      align: TextAlign.left,
    );
  }
}
