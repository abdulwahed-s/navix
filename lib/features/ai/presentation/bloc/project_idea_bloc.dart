import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/prd_entity.dart';
import '../../domain/entities/project_idea_entity.dart';
import '../../domain/entities/refined_idea_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/generate_prd_usecase.dart';
import '../../domain/usecases/generate_project_ideas_usecase.dart';

part 'project_idea_event.dart';
part 'project_idea_state.dart';

class ProjectIdeaBloc extends Bloc<ProjectIdeaEvent, ProjectIdeaState> {
  final GenerateProjectIdeasUseCase generateProjectIdeasUseCase;
  final GeneratePrdUseCase generatePrdUseCase;
  final AIRepository aiRepository;

  ProjectIdeaBloc({
    required this.generateProjectIdeasUseCase,
    required this.generatePrdUseCase,
    required this.aiRepository,
  }) : super(const IdeaInitial()) {
    on<GenerateIdeasRequested>(_onGenerateIdeasRequested);
    on<SelectIdea>(_onSelectIdea);
    on<ResetIdeas>(_onResetIdeas);
    on<RefineIdeaRequested>(_onRefineIdeaRequested);
    on<AcceptRefinedIdea>(_onAcceptRefinedIdea);
    on<GeneratePrdRequested>(_onGeneratePrdRequested);
  }

  Future<void> _onGenerateIdeasRequested(
    GenerateIdeasRequested event,
    Emitter<ProjectIdeaState> emit,
  ) async {
    emit(const IdeaLoading(message: 'Generating project ideas...'));

    final result = await generateProjectIdeasUseCase(
      GenerateIdeasParams(
        userSkills: event.userSkills,
        goals: event.goals,
        preferences: event.preferences,
        isTeamProject: event.isTeamProject,
      ),
    );

    result.fold(
      (failure) =>
          emit(IdeaError(message: failure.message, code: failure.code)),
      (ideas) => emit(IdeasGenerated(ideas)),
    );
  }

  void _onSelectIdea(SelectIdea event, Emitter<ProjectIdeaState> emit) {
    final currentState = state;
    if (currentState is IdeasGenerated) {
      emit(
        IdeaSelected(selectedIdea: event.idea, allIdeas: currentState.ideas),
      );
    }
  }

  void _onResetIdeas(ResetIdeas event, Emitter<ProjectIdeaState> emit) {
    emit(const IdeaInitial());
  }

  Future<void> _onRefineIdeaRequested(
    RefineIdeaRequested event,
    Emitter<ProjectIdeaState> emit,
  ) async {
    emit(const IdeaRefining());

    final result = await aiRepository.refineProjectIdea(
      ideaDescription: event.ideaDescription,
      userSkills: event.userSkills,
      additionalContext: event.additionalContext,
    );

    result.fold(
      (failure) =>
          emit(IdeaError(message: failure.message, code: failure.code)),
      (refinedIdea) => emit(IdeaRefined(refinedIdea)),
    );
  }

  void _onAcceptRefinedIdea(
    AcceptRefinedIdea event,
    Emitter<ProjectIdeaState> emit,
  ) {
    emit(RefinedIdeaAccepted(event.refinedIdea));
  }

  Future<void> _onGeneratePrdRequested(
    GeneratePrdRequested event,
    Emitter<ProjectIdeaState> emit,
  ) async {
    emit(const GeneratingPrd());

    final result = await generatePrdUseCase(
      GeneratePrdParams(
        selectedIdea: event.selectedIdea,
        userSkills: event.userSkills,
        isTeamProject: event.isTeamProject,
      ),
    );

    result.fold(
      (failure) =>
          emit(IdeaError(message: failure.message, code: failure.code)),
      (prd) => emit(PrdGenerated(prd: prd, selectedIdea: event.selectedIdea)),
    );
  }
}
