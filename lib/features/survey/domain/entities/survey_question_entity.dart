import 'package:equatable/equatable.dart';

enum SurveyQuestionType { radio, checkbox, text, rating }

class SurveyQuestionEntity extends Equatable {
  final String id;
  final SurveyQuestionType type;
  final String question;
  final List<String> options;
  final bool required;
  final bool allowOther;

  const SurveyQuestionEntity({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    this.required = true,
    this.allowOther = false,
  });

  bool get needsOptions =>
      type == SurveyQuestionType.radio || type == SurveyQuestionType.checkbox;

  @override
  List<Object?> get props => [
    id,
    type,
    question,
    options,
    required,
    allowOther,
  ];
}
