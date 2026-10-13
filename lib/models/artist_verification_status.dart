/// Status da verificação de identidade do artista (comportamento de produto).
///
/// Não há tela no fluxo legado para avançar além de [idle] — Spotify / contestação
/// estão ⛔. O enum existe para o formulário não inventar outro contrato.
enum ArtistVerificationStatus {
  idle,
  spotifyLinked,
  verified,
  manualReviewRequired,
  manualReviewSubmitted,
}
