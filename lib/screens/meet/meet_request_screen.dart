import 'package:crowdfans/api/api_error.dart';
import 'package:crowdfans/components/meet/meet_shared.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/video_call_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fã solicita Meet 1:1 com o artista.
class MeetRequestScreen extends StatefulWidget {
  const MeetRequestScreen({
    super.key,
    required this.artistUid,
    this.artistName,
    this.avatarUrl,
  });

  final String artistUid;
  final String? artistName;
  final String? avatarUrl;

  @override
  State<MeetRequestScreen> createState() => _MeetRequestScreenState();
}

class _MeetRequestScreenState extends State<MeetRequestScreen> {
  var _loading = false;
  String? _error;

  Future<void> handleRequest() async {
    if (_loading) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final call = await VideoCallService.request(widget.artistUid);
      if (!mounted) {
        return;
      }
      context.pushReplacement(
        Pages.meetWaitingOf(
          call.callId,
          artistName: widget.artistName ?? call.artistName,
          avatarUrl: widget.avatarUrl,
        ),
      );
    } on ApiError catch (error) {
      if (!mounted) {
        return;
      }
      if (error.status == 402) {
        setState(() => _loading = false);
        context.push(Pages.profileWalletRecharge);
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível solicitar a chamada.';
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
    final name = (widget.artistName ?? '').trim();
    return MeetScreenFrame(
      imageUrl: widget.avatarUrl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: handleBack,
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            const Spacer(),
            MeetPeerHeader(
              name: name.isEmpty ? 'Artista' : name,
              imageUrl: widget.avatarUrl,
              subtitle: 'Meet & Greet — 60 segundos · 60 Jam Coins',
            ),
            const SizedBox(height: 32),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppPalette.red300),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _loading ? null : handleRequest,
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.green500,
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Solicitar chamada'),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
