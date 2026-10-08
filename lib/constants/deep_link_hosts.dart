/// Hosts HTTPS usados em App Links / Universal Links (CF-357 / CF-356).
///
/// `staging.crowdfans.app` é **placeholder** até o DNS GCP staging existir
/// (CF-286 bloqueia apply). Trocar o host real no cutover sem mudar o scheme
/// custom `mobile://`.
abstract final class DeepLinkHosts {
  /// Produção (já usado em share: `https://crowdfans.app/posts/...`).
  static const prod = 'crowdfans.app';

  static const prodWww = 'www.crowdfans.app';

  /// Placeholder staging GCP — ainda sem DNS/LB.
  static const gcpStagingPlaceholder = 'staging.crowdfans.app';

  /// Lista estável para Android intent-filter / iOS associated domains.
  static const all = <String>[
    prod,
    prodWww,
    gcpStagingPlaceholder,
  ];

  /// True se [host] é um dos hosts de deep link conhecidos (incl. placeholder).
  static bool isKnown(String? host) {
    if (host == null || host.isEmpty) return false;
    final lower = host.toLowerCase();
    return all.any((h) => h == lower);
  }
}
