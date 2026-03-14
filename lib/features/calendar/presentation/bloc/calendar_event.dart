part of 'calendar_bloc.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends CalendarEvent {
  final String userId;

  const LoadEvents({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SelectDate extends CalendarEvent {
  final DateTime date;

  const SelectDate({required this.date});

  @override
  List<Object?> get props => [date];
}

class FilterByProject extends CalendarEvent {
  final String? projectId;

  const FilterByProject({this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class ChangeMonth extends CalendarEvent {
  final DateTime focusedDay;

  const ChangeMonth({required this.focusedDay});

  @override
  List<Object?> get props => [focusedDay];
}

class RefreshEvents extends CalendarEvent {
  final String userId;

  const RefreshEvents({required this.userId});

  @override
  List<Object?> get props => [userId];
}
