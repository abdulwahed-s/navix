import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../project/domain/entities/project_roadmap_entity.dart';
import '../../domain/entities/risk_prediction_entity.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../../domain/usecases/analyze_project_health_usecase.dart';

part 'prediction_event.dart';
part 'prediction_state.dart';

class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final AnalyzeProjectHealthUseCase analyzeProjectHealthUseCase;
  final PredictionRepository predictionRepository;

  String? _projectId;
  String? _projectName;
  ProjectRoadmapEntity? _roadmap;
  DateTime? _startDate;
  DateTime? _endDate;

  PredictionBloc({
    required this.analyzeProjectHealthUseCase,
    required this.predictionRepository,
  }) : super(const PredictionInitial()) {
    on<AnalyzeProjectRequested>(_onAnalyzeProjectRequested);
    on<LoadCachedPrediction>(_onLoadCachedPrediction);
    on<RefreshPrediction>(_onRefreshPrediction);
  }

  Future<void> _onAnalyzeProjectRequested(
    AnalyzeProjectRequested event,
    Emitter<PredictionState> emit,
  ) async {
    emit(const PredictionLoading());

    _projectId = event.projectId;
    _projectName = event.projectName;
    _roadmap = event.roadmap;
    _startDate = event.startDate;
    _endDate = event.endDate;

    final result = await analyzeProjectHealthUseCase(
      AnalyzeProjectParams(
        projectId: event.projectId,
        projectName: event.projectName,
        roadmap: event.roadmap,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(PredictionError(failure.message)),
      (prediction) => emit(PredictionLoaded(prediction)),
    );
  }

  Future<void> _onLoadCachedPrediction(
    LoadCachedPrediction event,
    Emitter<PredictionState> emit,
  ) async {
    emit(const PredictionLoading());

    _projectId = event.projectId;
    _projectName = event.projectName;
    _roadmap = event.roadmap;
    _startDate = event.startDate;
    _endDate = event.endDate;

    final result = await predictionRepository.getLatestPrediction(
      event.projectId,
    );

    result.fold((failure) => emit(PredictionError(failure.message)), (
      prediction,
    ) {
      if (prediction == null) {
        emit(const PredictionEmpty());
      } else {
        emit(PredictionLoaded(prediction));
      }
    });
  }

  Future<void> _onRefreshPrediction(
    RefreshPrediction event,
    Emitter<PredictionState> emit,
  ) async {
    if (_projectId == null || _roadmap == null) {
      emit(const PredictionError('No project loaded'));
      return;
    }

    add(
      AnalyzeProjectRequested(
        projectId: _projectId!,
        projectName: _projectName ?? '',
        roadmap: _roadmap!,
        startDate: _startDate ?? DateTime.now(),
        endDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      ),
    );
  }
}
