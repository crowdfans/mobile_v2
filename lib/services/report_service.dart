import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/services/http_service.dart';

/// Alvo persistido pelo backend.
enum ReportTargetType { user, post, comment }

/// Origem da denúncia na UI.
enum ReportContext { post, comment, artistProfile, fanProfile }

/// Motivo escolhido no fluxo de denúncia.
enum ReportReasonId {
  nudity,
  harassment,
  hate,
  violence,
  fraud,
  spam,
  falseInfo,
  other,
}

/// Opção exibida na lista de motivos.
class ReportReasonOption {
  const ReportReasonOption({
    required this.id,
    required this.label,
    required this.helper,
  });

  final ReportReasonId id;
  final String label;
  final String helper;
}

/// Denúncias (`POST /api/v1/reports`).
abstract final class ReportService {
  static const reasons = [
    ReportReasonOption(
      id: ReportReasonId.nudity,
      label: 'Nudez ou atividade sexual',
      helper: 'Conteúdo sexual explícito ou exposição indevida.',
    ),
    ReportReasonOption(
      id: ReportReasonId.harassment,
      label: 'Assédio ou bullying',
      helper: 'Ataques, intimidação ou perseguição direcionada.',
    ),
    ReportReasonOption(
      id: ReportReasonId.hate,
      label: 'Discurso de ódio',
      helper: 'Ofensas contra grupos protegidos ou conteúdo discriminatório.',
    ),
    ReportReasonOption(
      id: ReportReasonId.violence,
      label: 'Violência ou ameaça',
      helper: 'Ameaças, incentivo à violência ou conteúdo gráfico.',
    ),
    ReportReasonOption(
      id: ReportReasonId.fraud,
      label: 'Golpe ou fraude',
      helper: 'Tentativas de enganar, roubar ou aplicar golpes.',
    ),
    ReportReasonOption(
      id: ReportReasonId.spam,
      label: 'Spam',
      helper: 'Promoção excessiva, repetição ou conteúdo irrelevante.',
    ),
    ReportReasonOption(
      id: ReportReasonId.falseInfo,
      label: 'Informação falsa',
      helper: 'Conteúdo que engana ou espalha desinformação.',
    ),
    ReportReasonOption(
      id: ReportReasonId.other,
      label: 'Outro motivo',
      helper: 'O problema não se encaixa nas opções acima.',
    ),
  ];

  /// Converte query `context=` para o enum da tela.
  static ReportContext parseContext(String? raw) {
    return switch (raw) {
      'comment' => ReportContext.comment,
      'artist-profile' => ReportContext.artistProfile,
      'fan-profile' => ReportContext.fanProfile,
      _ => ReportContext.post,
    };
  }

  /// Tipo enviado ao backend.
  static ReportTargetType contextToTargetType(ReportContext context) {
    return switch (context) {
      ReportContext.comment => ReportTargetType.comment,
      ReportContext.post => ReportTargetType.post,
      ReportContext.artistProfile ||
      ReportContext.fanProfile => ReportTargetType.user,
    };
  }

  /// Título do header conforme o contexto.
  static String getReportTitle(ReportContext context) {
    return switch (context) {
      ReportContext.comment => 'Denunciar comentário',
      ReportContext.artistProfile => 'Denunciar perfil de artista',
      ReportContext.fanProfile => 'Denunciar perfil de fã',
      ReportContext.post => 'Denunciar publicação',
    };
  }

  static String _reasonApi(ReportReasonId id) {
    return switch (id) {
      ReportReasonId.nudity => 'nudity',
      ReportReasonId.harassment => 'harassment',
      ReportReasonId.hate => 'hate',
      ReportReasonId.violence => 'violence',
      ReportReasonId.fraud => 'fraud',
      ReportReasonId.spam => 'spam',
      ReportReasonId.falseInfo => 'false-info',
      ReportReasonId.other => 'other',
    };
  }

  static String _targetApi(ReportTargetType type) {
    return switch (type) {
      ReportTargetType.user => 'user',
      ReportTargetType.post => 'post',
      ReportTargetType.comment => 'comment',
    };
  }

  /// Envia a denúncia.
  static Future<void> createReport({
    required ReportTargetType targetType,
    required String targetId,
    required ReportReasonId reason,
    String? details,
  }) async {
    await HttpService.request<dynamic>(
      ApiUrls.reportCreate,
      method: Method.post,
      body: {
        'targetType': _targetApi(targetType),
        'targetId': targetId,
        'reason': _reasonApi(reason),
        if (details != null && details.isNotEmpty) 'details': details,
      },
    );
  }
}
