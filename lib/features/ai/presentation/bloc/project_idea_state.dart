part of 'project_idea_bloc.dart';

abstract class ProjectIdeaState extends Equatable {
  const ProjectIdeaState();

  @override
  List<Object?> get props => [];
}

class IdeaInitial extends ProjectIdeaState {
  const IdeaInitial();
}

class IdeaLoading extends ProjectIdeaState {
  final String? message;

  const IdeaLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class IdeasGenerated extends ProjectIdeaState {
  final List<ProjectIdeaEntity> ideas;

  const IdeasGenerated(this.ideas);

  @override
  List<Object?> get props => [ideas];
}

class IdeaSelected extends ProjectIdeaState {
  final ProjectIdeaEntity selectedIdea;
  final List<ProjectIdeaEntity> allIdeas;

  const IdeaSelected({required this.selectedIdea, required this.allIdeas});

  @override
  List<Object?> get props => [selectedIdea, allIdeas];
}

class IdeaError extends ProjectIdeaState {
  final String message;
  final String? code;

  const IdeaError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class IdeaRefining extends ProjectIdeaState {
  const IdeaRefining();
}

class IdeaRefined extends ProjectIdeaState {
  final RefinedIdeaEntity refinedIdea;

  const IdeaRefined(this.refinedIdea);

  @override
  List<Object?> get props => [refinedIdea];
}

class RefinedIdeaAccepted extends ProjectIdeaState {
  final RefinedIdeaEntity refinedIdea;

  const RefinedIdeaAccepted(this.refinedIdea);

  @override
  List<Object?> get props => [refinedIdea];
}

class GeneratingPrd extends ProjectIdeaState {
  const GeneratingPrd();
}

class PrdGenerated extends ProjectIdeaState {
  final PrdEntity prd;
  final ProjectIdeaEntity selectedIdea;

  const PrdGenerated({required this.prd, required this.selectedIdea});

  @override
  List<Object?> get props => [prd, selectedIdea];
}
