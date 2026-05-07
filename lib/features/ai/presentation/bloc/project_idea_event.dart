part of 'project_idea_bloc.dart';

abstract class ProjectIdeaEvent extends Equatable {
  const ProjectIdeaEvent();

  @override
  List<Object?> get props => [];
}

class GenerateIdeasRequested extends ProjectIdeaEvent {
  final List<String> userSkills;
  final String goals;
  final String? preferences;
  final bool isTeamProject;

  const GenerateIdeasRequested({
    required this.userSkills,
    required this.goals,
    this.preferences,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [userSkills, goals, preferences, isTeamProject];
}

class SelectIdea extends ProjectIdeaEvent {
  final ProjectIdeaEntity idea;

  const SelectIdea(this.idea);

  @override
  List<Object?> get props => [idea];
}

class ResetIdeas extends ProjectIdeaEvent {
  const ResetIdeas();
}

class RefineIdeaRequested extends ProjectIdeaEvent {
  final String ideaDescription;
  final List<String> userSkills;
  final String? additionalContext;

  const RefineIdeaRequested({
    required this.ideaDescription,
    required this.userSkills,
    this.additionalContext,
  });

  @override
  List<Object?> get props => [ideaDescription, userSkills, additionalContext];
}

class AcceptRefinedIdea extends ProjectIdeaEvent {
  final RefinedIdeaEntity refinedIdea;

  const AcceptRefinedIdea(this.refinedIdea);

  @override
  List<Object?> get props => [refinedIdea];
}

class GeneratePrdRequested extends ProjectIdeaEvent {
  final ProjectIdeaEntity selectedIdea;
  final List<String> userSkills;
  final bool isTeamProject;

  const GeneratePrdRequested({
    required this.selectedIdea,
    required this.userSkills,
    this.isTeamProject = false,
  });

  @override
  List<Object?> get props => [selectedIdea, userSkills, isTeamProject];
}
