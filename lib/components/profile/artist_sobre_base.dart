/// Rótulo de Base na aba Sobre — sem inventar localização.
String artistSobreBaseLabel(String? location) {
  final value = (location ?? '').trim();
  if (value.isEmpty) {
    return 'Não informado';
  }
  return value;
}
