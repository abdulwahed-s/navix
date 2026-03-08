abstract final class ApiConstants {
  static const String ollamaBaseUrl = 'http://10.0.2.2:11434';
  static const String ollamaGenerateEndpoint = '/api/generate';
  static const String ollamaChatEndpoint = '/api/chat';

  static const Duration connectTimeout = Duration(seconds: 300);
  static const Duration receiveTimeout = Duration(seconds: 300);
  static const Duration sendTimeout = Duration(seconds: 300);
}
