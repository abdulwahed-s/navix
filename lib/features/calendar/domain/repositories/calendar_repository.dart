import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/calendar_event_entity.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<CalendarEventEntity>>> getAllEvents(
    String userId,
  );

  Future<Either<Failure, List<CalendarEventEntity>>> getEventsByDate({
    required String userId,
    required DateTime date,
  });

  Future<Either<Failure, List<CalendarEventEntity>>> getEventsByProject({
    required String projectId,
  });

  Stream<List<CalendarEventEntity>> watchEvents(String userId);
}
