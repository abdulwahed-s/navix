import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prd_editor_context.dart';
import '../entities/prd_editor_message.dart';

abstract class PrdEditorRepository {
  Future<Either<Failure, PrdEditorMessage>> sendMessage({
    required String message,
    required List<PrdEditorMessage> history,
    required PrdEditorContext context,
  });
}
