import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/ai_chat_remote_datasource.dart';

class AIChatRepositoryImpl implements AIChatRepository {
  final AIChatRemoteDataSource remoteDataSource;

  AIChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> sendMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  }) async {
    try {
      final response = await remoteDataSource.sendMessage(
        message: message,
        chatHistory: chatHistory,
        context: context,
      );
      return Right(response);
    } on AIException catch (e) {
      return Left(AIFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        AIFailure(message: 'Failed to send message: $e', code: 'unknown'),
      );
    }
  }

  @override
  Stream<Either<Failure, String>> streamMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  }) async* {
    try {
      await for (final chunk in remoteDataSource.streamMessage(
        message: message,
        chatHistory: chatHistory,
        context: context,
      )) {
        yield Right(chunk);
      }
    } on AIException catch (e) {
      yield Left(AIFailure(message: e.message, code: e.code));
    } catch (e) {
      yield Left(
        AIFailure(message: 'Failed to stream message: $e', code: 'unknown'),
      );
    }
  }
}
