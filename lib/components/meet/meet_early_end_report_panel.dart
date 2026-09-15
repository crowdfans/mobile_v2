import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';

/// Motivos padrão do early-end report (artista).
const meetEarlyEndReportReasons = <String>[
  'Problema técnico',
  'Conduta inadequada',
  'Fã não apareceu no vídeo',
  'Outro',
];

/// Formulário obrigatório pós hangup antecipado.
class MeetEarlyEndReportPanel extends StatefulWidget {
  const MeetEarlyEndReportPanel({
    super.key,
    required this.busy,
    required this.onSubmit,
  });

  final bool busy;
  final void Function(String reason, String details) onSubmit;

  @override
  State<MeetEarlyEndReportPanel> createState() =>
      _MeetEarlyEndReportPanelState();
}

class _MeetEarlyEndReportPanelState extends State<MeetEarlyEndReportPanel> {
  String? _reason;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void handleSubmit() {
    final reason = _reason?.trim() ?? '';
    if (reason.isEmpty || widget.busy) {
      return;
    }
    widget.onSubmit(reason, _details.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final canSend = (_reason?.trim().isNotEmpty ?? false) && !widget.busy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'A chamada encerrou antes de 90s. Envie um report para liberar o próximo.',
          style: TextStyle(fontSize: 15, color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        for (final option in meetEarlyEndReportReasons) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: widget.busy
                  ? null
                  : () => setState(() => _reason = option),
              selected: _reason == option,
              selectedTileColor: AppPalette.green500.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _reason == option
                      ? AppPalette.green500
                      : colors.border,
                ),
              ),
              title: Text(option),
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: _details,
          enabled: !widget.busy,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Detalhes (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: canSend ? handleSubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.green500,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(widget.busy ? 'Enviando…' : 'Enviar report'),
        ),
      ],
    );
  }
}
