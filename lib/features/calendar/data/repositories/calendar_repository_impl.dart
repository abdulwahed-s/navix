import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final FirebaseFirestore firestore;

  CalendarRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, List<CalendarEventEntity>>> getAllEvents(
    String userId,
  ) async {
    try {
      final leaderQuery = await firestore
          .collection('projects')
          .where('leaderId', isEqualTo: userId)
          .get();

      final memberQuery = await firestore
          .collection('projects')
          .where('memberIds', arrayContains: userId)
          .get();

      final projectDocs = <String, DocumentSnapshot>{};
      for (final doc in leaderQuery.docs) {
        projectDocs[doc.id] = doc;
      }
      for (final doc in memberQuery.docs) {
        projectDocs[doc.id] = doc;
      }

      final events = <CalendarEventEntity>[];

      for (final projectDoc in projectDocs.values) {
        final projectId = projectDoc.id;
        final projectData = projectDoc.data() as Map<String, dynamic>?;
        final projectName = projectData?['name'] as String? ?? 'Project';
        final leaderId = projectData?['leaderId'] as String?;
        final isLeader = leaderId == userId;

        final milestonesQuery = await firestore
            .collection('projects')
            .doc(projectId)
            .collection('milestones')
            .get();

        for (final milestoneDoc in milestonesQuery.docs) {
          final milestoneData = milestoneDoc.data();
          final deadline = milestoneData['deadline'] as Timestamp?;
          if (deadline != null) {
            events.add(
              CalendarEventEntity(
                id: '${projectId}_milestone_${milestoneDoc.id}',
                title: milestoneData['name'] as String? ?? 'Milestone',
                projectId: projectId,
                projectName: projectName,
                date: deadline.toDate(),
                type: CalendarEventType.milestoneDeadline,
                description: milestoneData['description'] as String? ?? '',
                relatedId: milestoneDoc.id,
              ),
            );
          }
        }

        final QuerySnapshot<Map<String, dynamic>> tasksQuery;
        if (isLeader) {
          tasksQuery = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .get();
        } else {
          tasksQuery = await firestore
              .collection('projects')
              .doc(projectId)
              .collection('tasks')
              .where('assignedTo', isEqualTo: userId)
              .get();
        }

        for (final taskDoc in tasksQuery.docs) {
          final taskData = taskDoc.data();
          final deadline = taskData['deadline'] as Timestamp?;
          if (deadline != null) {
            events.add(
              CalendarEventEntity(
                id: taskDoc.id,
                title: taskData['name'] as String? ?? 'Task',
                projectId: projectId,
                projectName: projectName,
                date: deadline.toDate(),
                type: CalendarEventType.taskDeadline,
                description: taskData['description'] as String? ?? '',
                relatedId: taskDoc.id,
              ),
            );
          }
        }
      }

      events.sort((a, b) => a.date.compareTo(b.date));
      return Right(events);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get events: $e',
          code: 'calendar-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<CalendarEventEntity>>> getEventsByDate({
    required String userId,
    required DateTime date,
  }) async {
    final result = await getAllEvents(userId);
    return result.map((events) {
      return events.where((e) {
        return e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day;
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<CalendarEventEntity>>> getEventsByProject({
    required String projectId,
  }) async {
    try {
      final projectDoc = await firestore
          .collection('projects')
          .doc(projectId)
          .get();
      if (!projectDoc.exists) {
        return const Right([]);
      }

      final projectName = projectDoc.data()?['name'] as String? ?? 'Project';
      final events = <CalendarEventEntity>[];

      final tasksQuery = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .get();

      for (final taskDoc in tasksQuery.docs) {
        final taskData = taskDoc.data();
        final deadline = taskData['deadline'] as Timestamp?;
        if (deadline != null) {
          events.add(
            CalendarEventEntity(
              id: taskDoc.id,
              title: taskData['name'] as String? ?? 'Task',
              projectId: projectId,
              projectName: projectName,
              date: deadline.toDate(),
              type: CalendarEventType.taskDeadline,
              description: taskData['description'] as String? ?? '',
              relatedId: taskDoc.id,
            ),
          );
        }
      }

      events.sort((a, b) => a.date.compareTo(b.date));
      return Right(events);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get project events: $e',
          code: 'calendar-project-error',
        ),
      );
    }
  }

  @override
  Stream<List<CalendarEventEntity>> watchEvents(String userId) async* {
    final result = await getAllEvents(userId);
    yield result.fold((failure) => [], (events) => events);
  }
}
