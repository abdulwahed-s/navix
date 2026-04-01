import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_supervisor_context.dart';
import '../entities/supervisor_message.dart';
import '../repositories/project_supervisor_repository.dart';

class ChatWithSupervisorUseCase
    implements UseCase<SupervisorMessage, ChatWithSupervisorParams> {
  final ProjectSupervisorRepository repository;

  ChatWithSupervisorUseCase(this.repository);

  @override
  Future<Either<Failure, SupervisorMessage>> call(
    ChatWithSupervisorParams params,
  ) async {
    return await repository.sendMessage(
      message: params.message,
      history: params.history,
      context: params.context,
    );
  }
}

class ChatWithSupervisorParams extends Equatable {
  final String message;

  final List<SupervisorMessage> history;

  final ProjectSupervisorContext context;

  const ChatWithSupervisorParams({
    required this.message,
    required this.history,
    required this.context,
  });

  @override
  List<Object?> get props => [message, history, context];
}
