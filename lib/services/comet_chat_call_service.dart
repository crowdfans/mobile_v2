import 'dart:async';

import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart';
import 'package:crowdfans/models/video_call.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Resultado de entrar na sala CometChat (ou sandbox).
class CometChatJoinResult {
  const CometChatJoinResult({
    required this.sandbox,
    this.callWidget,
    this.message = '',
  });

  final bool sandbox;
  final Widget? callWidget;
  final String message;
}

/// Integração CometChat Calls (CF-30).
///
/// Sem credenciais reais o backend devolve `sandbox: true` — UI + timer/WS
/// funcionam sem WebRTC. Com App ID real: init → login → joinSession.
abstract final class CometChatCallService {
  static String? _initializedAppId;

  /// Entra na sessão de vídeo. Em sandbox não chama o SDK nativo.
  static Future<CometChatJoinResult> join(VideoCall call) async {
    if (call.sandbox ||
        call.cometAppId.isEmpty ||
        call.cometAppId == 'sandbox' ||
        call.authToken.startsWith('sandbox-')) {
      return const CometChatJoinResult(
        sandbox: true,
        message: 'Modo sandbox — timer sincronizado pelo servidor.',
      );
    }

    await _ensureInitialized(call.cometAppId, call.cometRegion);
    await _login(call.authToken);

    final settings = SessionSettingsBuilder()
        .setType(SessionType.video)
        .hideSessionTimer(true)
        .setTitle('Meet & Greet')
        .build();

    final completer = Completer<CometChatJoinResult>();

    unawaited(
      CometChatCalls.joinSession(
        sessionId: call.roomId,
        sessionSettings: settings,
        onSuccess: (widget) {
          if (!completer.isCompleted) {
            completer.complete(
              CometChatJoinResult(sandbox: false, callWidget: widget),
            );
          }
        },
        onError: (error) {
          if (kDebugMode) {
            debugPrint('[cometchat] joinSession: ${error.message}');
          }
          _joinViaToken(call, settings, completer);
        },
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 20),
      onTimeout: () => const CometChatJoinResult(
        sandbox: true,
        message: 'Timeout ao entrar no CometChat — seguindo com timer local.',
      ),
    );
  }

  static void _joinViaToken(
    VideoCall call,
    SessionSettings settings,
    Completer<CometChatJoinResult> completer,
  ) {
    CometChatCalls.generateToken(
      call.roomId,
      call.authToken,
      onSuccess: (GenerateToken token) {
        final callToken = token.token;
        if (callToken == null || callToken.isEmpty) {
          if (!completer.isCompleted) {
            completer.complete(
              const CometChatJoinResult(
                sandbox: true,
                message: 'Token CometChat vazio — timer local.',
              ),
            );
          }
          return;
        }
        unawaited(
          CometChatCalls.joinSession(
            callToken: CallToken(token: callToken),
            sessionSettings: settings,
            onSuccess: (widget) {
              if (!completer.isCompleted) {
                completer.complete(
                  CometChatJoinResult(sandbox: false, callWidget: widget),
                );
              }
            },
            onError: (error) {
              if (!completer.isCompleted) {
                completer.complete(
                  CometChatJoinResult(
                    sandbox: true,
                    message: error.message ?? 'Falha CometChat',
                  ),
                );
              }
            },
          ),
        );
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.complete(
            CometChatJoinResult(
              sandbox: true,
              message: error.message ?? 'Falha ao gerar token CometChat',
            ),
          );
        }
      },
    );
  }

  static Future<void> leave() async {
    final end = Completer<void>();
    CometChatCalls.endSession(
      onSuccess: (_) {
        if (!end.isCompleted) {
          end.complete();
        }
      },
      onError: (_) {
        if (!end.isCompleted) {
          end.complete();
        }
      },
    );
    await end.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );

    final logout = Completer<void>();
    CometChatCalls.logout(
      onSuccess: (_) {
        if (!logout.isCompleted) {
          logout.complete();
        }
      },
      onError: (_) {
        if (!logout.isCompleted) {
          logout.complete();
        }
      },
    );
    await logout.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );
  }

  static Future<void> _ensureInitialized(String appId, String region) async {
    if (CometChatCalls.isInitialized && _initializedAppId == appId) {
      return;
    }
    final settings = (CallAppSettingBuilder()
          ..appId = appId
          ..region = region)
        .build();
    final completer = Completer<void>();
    CometChatCalls.init(
      settings,
      onSuccess: (_) {
        _initializedAppId = appId;
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(
            StateError(error.message ?? 'Falha ao iniciar CometChat'),
          );
        }
      },
    );
    await completer.future.timeout(const Duration(seconds: 15));
  }

  static Future<void> _login(String authToken) async {
    final completer = Completer<void>();
    CometChatCalls.loginWithAuthToken(
      authToken: authToken,
      onSuccess: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(
            StateError(error.message ?? 'Falha no login CometChat'),
          );
        }
      },
    );
    await completer.future.timeout(const Duration(seconds: 15));
  }
}
