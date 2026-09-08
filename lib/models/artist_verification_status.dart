/// Status da verificação de identidade do artista (espelho do Expo).
///
/// Não há tela no Expo para avançar além de [idle] — Spotify / contestação
/// estão ⛔. O enum existe para o formulário não inventar outro contrato.
enum ArtistVerificationStatus {
  idle,
  spotifyLinked,
  verified,
  manualReviewRequired,
  manualReviewSubmitted,
}
