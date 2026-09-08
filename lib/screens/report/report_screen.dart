import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/report/report_reason_row.dart';
import 'package:crowdfans/components/report/report_success_box.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/hidden_post_service.dart';
import 'package:crowdfans/services/report_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _ReportStep { reason, details, success }

/// Fluxo de denúncia (motivo → detalhes → sucesso).
class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.contextKind,
    this.targetId,
    this.displayName,
  });

  final ReportContext contextKind;
  final String? targetId;
  final String? displayName;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  var _step = _ReportStep.reason;
  ReportReasonId? _reason;
  var _details = '';
  var _submitting = false;

  void handleClose() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  void handleBack() {
    if (_step == _ReportStep.details) {
      setState(() => _step = _ReportStep.reason);
      return;
    }
    handleClose();
  }

  void handleSelectReason(ReportReasonId id) {
    setState(() {
      _reason = id;
      _step = _ReportStep.details;
    });
  }

  Future<void> handleSubmit() async {
    final targetId = widget.targetId?.trim() ?? '';
    final reason = _reason;
    if (targetId.isEmpty || reason == null) {
      await AppAlert.show(
        context,
        title: 'Denúncia',
        message: 'Alvo da denúncia inválido.',
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ReportService.createReport(
        targetType: ReportService.contextToTargetType(widget.contextKind),
        targetId: targetId,
        reason: reason,
        details: _details.trim().isEmpty ? null : _details.trim(),
      );
      if (widget.contextKind == ReportContext.post) {
        try {
          await HiddenPostService.hidePost(targetId);
        } catch (_) {}
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _step = _ReportStep.success;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      await AppAlert.show(
        context,
        title: 'Denúncia',
        message: error.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final title = ReportService.getReportTitle(widget.contextKind);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _step == _ReportStep.success
                        ? handleClose
                        : handleBack,
                    child: Text(
                      _step == _ReportStep.success ? 'Fechar' : 'Voltar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 72),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                children: [
                  if (_step == _ReportStep.reason) ...[
                    Text(
                      (widget.displayName ?? '').isNotEmpty
                          ? 'Por que você está denunciando ${widget.displayName}?'
                          : 'Selecione o motivo da denúncia.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final option in ReportService.reasons)
                      ReportReasonRow(
                        option: option,
                        onPressed: () => handleSelectReason(option.id),
                      ),
                  ],
                  if (_step == _ReportStep.details) ...[
                    Text(
                      'Quer adicionar detalhes? (opcional, até 400 caracteres)',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      hint: 'Descreva o que aconteceu',
                      maxLines: 5,
                      onChanged: (value) {
                        _details = value.length > 400
                            ? value.substring(0, 400)
                            : value;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_submitting)
                      const Center(child: CircularProgressIndicator())
                    else
                      AppButton(
                        label: 'Enviar denúncia',
                        onPressed: handleSubmit,
                      ),
                  ],
                  if (_step == _ReportStep.success)
                    ReportSuccessBox(onClose: handleClose),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
