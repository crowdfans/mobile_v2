/// Estados visuais do player de vídeo no feed (CF-232).
enum PostVideoUiState {
  /// Idle / carregado sem reproduzir (print: play-slash + mute + 00:00).
  idle,

  /// Inicializando o controller.
  loading,

  /// Pronto / pausado após load (mesma chrome do idle, pode ter frame).
  ready,

  /// Buffer durante reprodução.
  buffering,

  /// Falha de carga ou URL ausente.
  error,
}
