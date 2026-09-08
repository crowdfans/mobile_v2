/// Erro HTTP da API CrowdFans.
class ApiError implements Exception {
  ApiError(this.message, this.status);

  final String message;
  final int status;

  bool get isUnauthorized => status == 401;

  @override
  String toString() => message;
}
