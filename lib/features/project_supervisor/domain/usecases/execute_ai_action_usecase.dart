import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_action.dart';
import '../repositories/project_supervisor_repository.dart';

class ExecuteAIActionUseCase implements UseCase<void, ExecuteAIActionParams> {
  final ProjectSupervisorRepository repository;

  ExecuteAIActionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ExecuteAIActionParams params) async {
    return await repository.executeAction(
      action: params.action,
      projectId: params.projectId,
    );
  }
}

class ExecuteAIActionParams extends Equatable {
  final AIAction action;

  final String projectId;

  const ExecuteAIActionParams({required this.action, required this.projectId});

  @override
  List<Object?> get props => [action, projectId];
}
