import 'package:crowdfans/components/buttons/app_button.dart';
import 'package:crowdfans/components/profile/profile_screen_header.dart';
import 'package:crowdfans/constants/pages.dart';
import 'package:crowdfans/constants/theme.dart';
import 'package:crowdfans/services/referral_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Código de convite do viewer.
class ProfileReferralScreen extends StatefulWidget {
  const ProfileReferralScreen({super.key});

  @override
  State<ProfileReferralScreen> createState() => _ProfileReferralScreenState();
}

class _ProfileReferralScreenState extends State<ProfileReferralScreen> {
  ReferralInfo? _info;
  var _copied = false;
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
    context.go(Pages.profileSettings);
  }

  Future<void> handleLoad() async {
    try {
      final info = await ReferralService.getMyReferral();
      if (!mounted) {
        return;
      }
      setState(() {
        _info = info;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () => _error = 'Não foi possível carregar seu código de convite.',
      );
    }
  }

  Future<void> handleCopy() async {
    final code = _info?.code.trim() ?? '';
    if (code.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      setState(() => _copied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final info = _info;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileScreenHeader(title: 'Indique amigos', onBack: handleBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Text(
                'Compartilhe seu código. Quem se cadastrar com ele fica vinculado a você. A carteira de Jam Coins já existe; o bônus automático de indicação ainda não.',
                style: TextStyle(
                  fontSize: 14,
                  height: 21 / 14,
                  color: colors.textSecondary,
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error!, style: TextStyle(color: colors.danger)),
              ),
            if (info != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SEU CÓDIGO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          info.code,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${info.referredCount} amigo(s) usaram seu código.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: _copied ? 'Copiado' : 'Copiar código',
                          onPressed: handleCopy,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
