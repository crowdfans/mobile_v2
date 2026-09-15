import 'dart:async';

import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/services/meet_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Entrada `/meet` do artista: cria ou retoma evento e abre o host.
class MeetHostScreen extends StatefulWidget {
  const MeetHostScreen({super.key});

  @override
  State<MeetHostScreen> createState() => _MeetHostScreenState();
}

class _MeetHostScreenState extends State<MeetHostScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    handleBootstrap();
  }

  Future<void> handleBootstrap() async {
    try {
      final snap = await MeetEventService.createOrResume();
      if (!mounted) {
        return;
      }
      context.pushReplacement(Pages.meetEventHostOf(snap.eventId));
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[meet-event] host bootstrap: $error');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error is ApiError
            ? error.message
            : 'Não foi possível abrir o Meet & Greet.';
      });
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: handleBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Meet & Greet'),
      ),
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() => _error = null);
                        handleBootstrap();
                      },
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
