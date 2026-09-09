import 'package:crowdfans/components/fan_letter/fan_letter_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/fan_letter_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Galeria das fan letters enviadas pelo viewer.
class FanLetterGalleryScreen extends StatefulWidget {
  const FanLetterGalleryScreen({super.key});

  @override
  State<FanLetterGalleryScreen> createState() => _FanLetterGalleryScreenState();
}

class _FanLetterGalleryScreenState extends State<FanLetterGalleryScreen> {
  var _letters = <FanLetter>[];
  var _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  Future<void> handleLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final letters = await FanLetterService.listMyFanLetters();
      if (!mounted) {
        return;
      }
      setState(() {
        _letters = letters;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar suas cartas.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(title: 'Minhas Fan Letters', onBack: handleBack),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: handleLoad,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          else if (_letters.isEmpty) ...[
                            const SizedBox(height: 48),
                            Text(
                              'Nenhuma carta ainda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Envie uma Fan Letter pelo perfil do artista.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.push(Pages.explore),
                              child: const Text('Buscar artista'),
                            ),
                          ] else
                            for (final letter in _letters) ...[
                              FanLetterCard(letter: letter),
                              const SizedBox(height: 12),
                            ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
