import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/calendar_event_entity.dart';
import '../repositories/calendar_repository.dart';

class GetAllEventsUseCase
    implements UseCase<List<CalendarEventEntity>, String> {
  final CalendarRepository repository;

  GetAllEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CalendarEventEntity>>> call(String userId) {
    return repository.getAllEvents(userId);
  }
}
