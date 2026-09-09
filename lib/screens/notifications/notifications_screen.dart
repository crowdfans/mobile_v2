import 'package:crowdfans/components/notifications/notification_filter_chip.dart';
import 'package:crowdfans/components/notifications/notification_item_card.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

/// Inbox de notificações (espelho do `NotificationsScreen` / mock PDF).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  var _sections = <NotificationSection>[];
  var _tab = NotificationTab.all;
  var _loading = true;
  var _refreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    handleLoad();
  }

  Future<void> handleLoad({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        _refreshing = true;
      } else {
        _loading = true;
      }
      _error = null;
    });
    try {
      final sections = await NotificationsService.getNotifications();
      if (!mounted) {
        return;
      }
      setState(() => _sections = sections);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _error = refresh
            ? 'Não foi possível atualizar.'
            : 'Não foi possível carregar as notificações.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  void handleBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(Pages.home);
  }

  void handleOpen(NotificationItem item) {
    final route = (item.targetRoute ?? '').trim();
    if (route.isEmpty) {
      return;
    }
    final mapped = Pages.fromIncomingLocation(route);
    context.push(mapped);
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final filtered = NotificationsService.filterSectionsByTab(_sections, _tab);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: handleBack,
                    tooltip: 'Voltar',
                    icon: Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: colors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Notificações',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(Pages.profileNotifications),
                    tooltip: 'Preferências',
                    icon: SvgPicture.asset(
                      'assets/icons/General/settings-02.svg',
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        colors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final tab in NotificationTab.values) ...[
                    NotificationFilterChip(
                      tab: tab,
                      selected: _tab == tab,
                      onPressed: () => setState(() => _tab = tab),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => handleLoad(refresh: true),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          else if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'Nenhuma notificação nesta aba ainda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          else
                            for (final section in filtered) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  section.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              for (final item in section.items)
                                NotificationItemCard(
                                  item: item,
                                  onPressed: () => handleOpen(item),
                                ),
                            ],
                          if (_refreshing) const SizedBox(height: 12),
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
