import 'package:equatable/equatable.dart';

class SurveyResponseEntity extends Equatable {
  final String id;
  final String surveyId;
  final String respondentId;
  final String respondentName;
  final DateTime submittedAt;

  final Map<String, dynamic> answers;

  const SurveyResponseEntity({
    required this.id,
    required this.surveyId,
    required this.respondentId,
    required this.respondentName,
    required this.submittedAt,
    required this.answers,
  });

  dynamic getAnswer(String questionId) => answers[questionId];

  bool hasAnswer(String questionId) =>
      answers.containsKey(questionId) && answers[questionId] != null;

  @override
  List<Object?> get props => [
    id,
    surveyId,
    respondentId,
    respondentName,
    submittedAt,
    answers,
  ];
}
