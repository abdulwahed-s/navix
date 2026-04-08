import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../project/domain/entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskStatusUseCase implements UseCase<void, UpdateTaskStatusParams> {
  final TaskRepository repository;

  UpdateTaskStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateTaskStatusParams params) {
    return repository.updateTaskStatus(
      projectId: params.projectId,
      taskId: params.taskId,
      newStatus: params.newStatus,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateTaskStatusParams extends Equatable {
  final String projectId;
  final String taskId;
  final TaskStatus newStatus;
  final String updatedBy;

  const UpdateTaskStatusParams({
    required this.projectId,
    required this.taskId,
    required this.newStatus,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [projectId, taskId, newStatus, updatedBy];
}
