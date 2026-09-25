import 'package:crowdfans/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Rótulo legível para QA a partir de `version` + `buildNumber` do pubspec.
///
/// Ex.: `0.1.1 (2)`.
String formatAppVersionLabel(String version, String buildNumber) {
  final v = version.trim();
  final b = buildNumber.trim();
  if (v.isEmpty) {
    return b.isEmpty ? '' : '($b)';
  }
  if (b.isEmpty) {
    return v;
  }
  return '$v ($b)';
}

/// Rodapé de versão no hub de Configurações (fonte: `package_info_plus`).
///
/// Toque copia o texto para a área de transferência (útil em bug reports).
class SettingsAppVersion extends StatefulWidget {
  const SettingsAppVersion({super.key});

  @override
  State<SettingsAppVersion> createState() => _SettingsAppVersionState();
}

class _SettingsAppVersionState extends State<SettingsAppVersion> {
  String? _label;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _label = formatAppVersionLabel(info.version, info.buildNumber);
    });
  }

  Future<void> handleCopy() async {
    final label = _label;
    if (label == null || label.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: label));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Versão copiada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = CrowdFansTheme.of(context);
    final label = _label;
    if (label == null || label.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Center(
        child: InkWell(
          key: const Key('settings-app-version'),
          onTap: handleCopy,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
