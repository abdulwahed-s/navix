abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({required super.message, super.code, this.statusCode});

  @override
  String toString() =>
      'ServerException: $message (status: $statusCode, code: $code)';
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

class AIException extends AppException {
  final int? statusCode;

  const AIException({required super.message, super.code, this.statusCode});

  @override
  String toString() =>
      'AIException: $message (status: $statusCode, code: $code)';
}

class FirebaseAppException extends AppException {
  const FirebaseAppException({required super.message, super.code});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}
