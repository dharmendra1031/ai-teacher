class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() {
    final String code = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$code: $message';
  }
}

class ApiConfigurationException extends ApiException {
  const ApiConfigurationException(super.message);
}
