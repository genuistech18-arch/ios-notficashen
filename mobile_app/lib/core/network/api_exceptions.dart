sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
}

class CodeNotFoundException extends ApiException {
  const CodeNotFoundException() : super('Code not found');
}

class NetworkException extends ApiException {
  const NetworkException() : super('Network error, please check your connection');
}

class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Something went wrong']);
}
