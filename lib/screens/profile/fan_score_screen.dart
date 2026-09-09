import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/input/app_text_field.dart';
import 'package:crowdfans/components/profile/fan_score_artist_card.dart';
import 'package:crowdfans/components/profile/fan_score_cycle_card.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/components/profile/profile_state.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/models/fan_score.dart';
import 'package:crowdfans/services/profile_service.dart';
import 'package:crowdfans/utils/app_alert.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// FanScore público por handle (mock Fanscore).
class FanScoreScreen extends StatefulWidget {
  const FanScoreScreen({super.key, required this.fanHandle});

  final String fanHandle;

  @override
  State<FanScoreScreen> createState() => _FanScoreScreenState();
}

class _FanScoreScreenState extends State<FanScoreScreen> {
  FanScoreData? _data;
  var _loading = true;
  String? _error;
  String? _expandedArtistId;
  var _search = '';

  String get _handle {
    return ProfileService.normalizeFanHandle(
      Uri.decodeComponent(widget.fanHandle),
    );
  }

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad() async {
    final handle = _handle;
    if (handle.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Handle inválido.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ProfileService.getFanScore(handle);
      if (!mounted) {
        return;
      }
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _data = null;
        _loading = false;
        _error = 'Não foi possível carregar o Fan Score.';
      });
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.me);
  }

  void handleToggleInsights(String artistId) {
    setState(() {
      _expandedArtistId = _expandedArtistId == artistId ? null : artistId;
    });
  }

  Future<void> handleOpenInfo() async {
    await AppAlert.show(
      context,
      title: 'Como funciona o FanScore',
      message:
          'Há um score diferente para cada artista, recalculado a cada ciclo mensal. '
          'O ranking compara você com outros fãs do mesmo artista. '
          'Membership e doações pesam mais na pontuação.',
    );
  }

  List<FanScoreEntry> filteredEntries() {
    final entries = _data?.entries ?? const <FanScoreEntry>[];
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) {
      return entries;
    }
    return [
      for (final entry in entries)
        if (entry.artistName.toLowerCase().contains(query)) entry,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final entries = filteredEntries();
    final cycle = _data?.cycleDetails;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ProfileScreenHeader(
              title: 'FanScore',
              onBack: handleBack,
              action: IconButton(
                onPressed: handleOpenInfo,
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: colors.textPrimary,
                ),
                tooltip: 'Como funciona',
              ),
            ),
            Expanded(
              child: _loading
                  ? const ProfileState(loading: true)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      children: [
                        if (_error != null) ...[
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Tentar novamente',
                            onPressed: handleLoad,
                          ),
                        ],
                        if (cycle != null) ...[
                          FanScoreCycleCard(details: cycle),
                          const SizedBox(height: 14),
                        ],
                        if (_error == null) ...[
                          AppTextField(
                            hint: 'Buscar artista',
                            onChanged: (value) {
                              setState(() => _search = value);
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (_error == null && entries.isEmpty)
                          Text(
                            _search.trim().isEmpty
                                ? 'Sem scores ainda. Assine artistas para começar a pontuar.'
                                : 'Nenhum artista encontrado para essa busca.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          )
                        else
                          for (final entry in entries) ...[
                            FanScoreArtistCard(
                              entry: entry,
                              expanded: _expandedArtistId == entry.artistId,
                              onToggleInsights: () =>
                                  handleToggleInsights(entry.artistId),
                            ),
                            const SizedBox(height: 12),
                          ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
