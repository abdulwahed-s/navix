import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../project/domain/entities/project_entity.dart';
import '../../../project/domain/usecases/get_user_projects_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProjectsUseCase getUserProjectsUseCase;

  HomeBloc({required this.getUserProjectsUseCase})
    : super(const HomeInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<RefreshProjects>(_onRefreshProjects);
    on<ProjectsUpdated>(_onProjectsUpdated);
    on<SelectProject>(_onSelectProject);
  }

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    final result = await getUserProjectsUseCase(
      GetUserProjectsParams(userId: event.userId),
    );

    result.fold((failure) => emit(HomeError(failure.message)), (projects) {
      if (projects.isEmpty) {
        emit(const HomeEmpty());
      } else {
        emit(ProjectsLoaded(projects));
      }
    });
  }

  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getUserProjectsUseCase(
      GetUserProjectsParams(userId: event.userId),
    );

    result.fold((failure) => emit(HomeError(failure.message)), (projects) {
      if (projects.isEmpty) {
        emit(const HomeEmpty());
      } else {
        emit(ProjectsLoaded(projects));
      }
    });
  }

  void _onProjectsUpdated(ProjectsUpdated event, Emitter<HomeState> emit) {
    if (event.projects.isEmpty) {
      emit(const HomeEmpty());
    } else {
      emit(ProjectsLoaded(event.projects));
    }
  }

  void _onSelectProject(SelectProject event, Emitter<HomeState> emit) {}
}
