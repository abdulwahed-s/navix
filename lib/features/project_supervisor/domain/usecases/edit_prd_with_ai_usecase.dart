import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prd_editor_context.dart';
import '../entities/prd_editor_message.dart';
import '../repositories/prd_editor_repository.dart';

class EditPrdWithAIUseCase
    implements UseCase<PrdEditorMessage, EditPrdWithAIParams> {
  final PrdEditorRepository repository;

  EditPrdWithAIUseCase(this.repository);

  @override
  Future<Either<Failure, PrdEditorMessage>> call(EditPrdWithAIParams params) {
    return repository.sendMessage(
      message: params.message,
      history: params.history,
      context: params.context,
    );
  }
}

class EditPrdWithAIParams extends Equatable {
  final String message;
  final List<PrdEditorMessage> history;
  final PrdEditorContext context;

  const EditPrdWithAIParams({
    required this.message,
    required this.history,
    required this.context,
  });

  @override
  List<Object?> get props => [message, history, context];
}
