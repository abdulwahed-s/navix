import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ai_action.dart';
import '../entities/project_supervisor_context.dart';
import '../entities/supervisor_message.dart';

abstract class ProjectSupervisorRepository {
  Future<Either<Failure, SupervisorMessage>> sendMessage({
    required String message,
    required List<SupervisorMessage> history,
    required ProjectSupervisorContext context,
  });

  Future<Either<Failure, void>> executeAction({
    required AIAction action,
    required String projectId,
  });
}
