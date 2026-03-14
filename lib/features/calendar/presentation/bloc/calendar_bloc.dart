import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/usecases/get_all_events_usecase.dart';

part 'calendar_event.dart';
part 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final GetAllEventsUseCase getAllEventsUseCase;

  List<CalendarEventEntity> _allEvents = [];

  CalendarBloc({required this.getAllEventsUseCase})
    : super(const CalendarInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<SelectDate>(_onSelectDate);
    on<FilterByProject>(_onFilterByProject);
    on<ChangeMonth>(_onChangeMonth);
    on<RefreshEvents>(_onRefreshEvents);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoading());

    final result = await getAllEventsUseCase(event.userId);

    result.fold((failure) => emit(CalendarError(failure.message)), (events) {
      _allEvents = events;
      emit(
        CalendarLoaded(
          allEvents: events,
          filteredEvents: events,
          selectedDate: DateTime.now(),
          focusedDay: DateTime.now(),
        ),
      );
    });
  }

  void _onSelectDate(SelectDate event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(selectedDate: event.date));
    }
  }

  void _onFilterByProject(FilterByProject event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      if (event.projectId == null) {
        emit(
          currentState.copyWith(
            filteredEvents: _allEvents,
            clearProjectFilter: true,
          ),
        );
      } else {
        final filtered = _allEvents
            .where((e) => e.projectId == event.projectId)
            .toList();
        emit(
          currentState.copyWith(
            filteredEvents: filtered,
            selectedProjectId: event.projectId,
          ),
        );
      }
    }
  }

  void _onChangeMonth(ChangeMonth event, Emitter<CalendarState> emit) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      emit(currentState.copyWith(focusedDay: event.focusedDay));
    }
  }

  Future<void> _onRefreshEvents(
    RefreshEvents event,
    Emitter<CalendarState> emit,
  ) async {
    final currentState = state;
    final result = await getAllEventsUseCase(event.userId);

    result.fold((failure) => emit(CalendarError(failure.message)), (events) {
      _allEvents = events;
      if (currentState is CalendarLoaded) {
        final filteredEvents = currentState.selectedProjectId != null
            ? events
                  .where((e) => e.projectId == currentState.selectedProjectId)
                  .toList()
            : events;
        emit(
          currentState.copyWith(
            allEvents: events,
            filteredEvents: filteredEvents,
          ),
        );
      } else {
        emit(
          CalendarLoaded(
            allEvents: events,
            filteredEvents: events,
            selectedDate: DateTime.now(),
            focusedDay: DateTime.now(),
          ),
        );
      }
    });
  }
}
