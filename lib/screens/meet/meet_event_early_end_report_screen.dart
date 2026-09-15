import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/meet/meet_early_end_report_panel.dart';
import 'package:crowdfans/components/toolbar/toolbar_back_button.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Report obrigatório após early-end (libera `call_next`).
class MeetEventEarlyEndReportScreen extends StatefulWidget {
  const MeetEventEarlyEndReportScreen({
    super.key,
    required this.callId,
    required this.eventId,
  });

  final String callId;
  final String eventId;

  @override
  State<MeetEventEarlyEndReportScreen> createState() =>
      _MeetEventEarlyEndReportScreenState();
}

class _MeetEventEarlyEndReportScreenState
    extends State<MeetEventEarlyEndReportScreen> {
  var _busy = false;
  String? _error;

  Future<void> handleSubmit(String reason, String details) async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await MeetEventService.earlyEndReport(
        widget.callId,
        reason: reason,
        details: details,
      );
      if (!mounted) {
        return;
      }
      if (context.canPop()) {
        context.pop(true);
        return;
      }
      context.go(Pages.meetEventHostOf(widget.eventId));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] early-end report: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _busy = false;
        _error = error is ApiError
            ? error.message
            : 'Não foi possível enviar o report.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: ToolbarBackButton(
            onPressed: () {
              // Bloqueia saída sem report — só volta se já não há pendência.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Envie o report para continuar.'),
                ),
              );
            },
          ),
          title: const Text('Report early-end'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: const TextStyle(color: AppPalette.red500),
              ),
              const SizedBox(height: 12),
            ],
            MeetEarlyEndReportPanel(
              busy: _busy,
              onSubmit: handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
