part of 'calendar_bloc.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoading extends CalendarState {
  const CalendarLoading();
}

class CalendarLoaded extends CalendarState {
  final List<CalendarEventEntity> allEvents;
  final List<CalendarEventEntity> filteredEvents;
  final DateTime selectedDate;
  final DateTime focusedDay;
  final String? selectedProjectId;

  const CalendarLoaded({
    required this.allEvents,
    required this.filteredEvents,
    required this.selectedDate,
    required this.focusedDay,
    this.selectedProjectId,
  });

  List<CalendarEventEntity> getEventsForDay(DateTime day) {
    return (selectedProjectId == null ? allEvents : filteredEvents).where((e) {
      return e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day;
    }).toList();
  }

  List<CalendarEventEntity> get selectedDateEvents {
    return (selectedProjectId == null ? allEvents : filteredEvents).where((e) {
      return e.date.year == selectedDate.year &&
          e.date.month == selectedDate.month &&
          e.date.day == selectedDate.day;
    }).toList();
  }

  List<({String id, String name})> get projects {
    final seen = <String>{};
    return allEvents
        .where((e) => seen.add(e.projectId))
        .map((e) => (id: e.projectId, name: e.projectName))
        .toList();
  }

  CalendarLoaded copyWith({
    List<CalendarEventEntity>? allEvents,
    List<CalendarEventEntity>? filteredEvents,
    DateTime? selectedDate,
    DateTime? focusedDay,
    String? selectedProjectId,
    bool clearProjectFilter = false,
  }) {
    return CalendarLoaded(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedProjectId: clearProjectFilter
          ? null
          : (selectedProjectId ?? this.selectedProjectId),
    );
  }

  @override
  List<Object?> get props => [
    allEvents,
    filteredEvents,
    selectedDate,
    focusedDay,
    selectedProjectId,
  ];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}
