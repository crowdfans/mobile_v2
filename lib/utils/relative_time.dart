/// Tempo relativo do feed a partir de minutos desde a publicação.
String formatMinutesAgo(int minutes) {
  if (minutes < 1) {
    return 'agora';
  }
  if (minutes == 1) {
    return '1 minuto atrás';
  }
  if (minutes < 60) {
    return '$minutes minutos atrás';
  }
  final hours = minutes ~/ 60;
  if (hours == 1) {
    return '1 hora atrás';
  }
  if (hours < 24) {
    return '$hours horas atrás';
  }
  final days = hours ~/ 24;
  if (days == 1) {
    return '1 dia atrás';
  }
  return '$days dias atrás';
}
