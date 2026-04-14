import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_question_entity.dart';
import '../../domain/entities/survey_response_entity.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';

class TakeSurveyScreen extends StatefulWidget {
  final String projectId;
  final String surveyId;

  const TakeSurveyScreen({
    super.key,
    required this.projectId,
    required this.surveyId,
  });

  @override
  State<TakeSurveyScreen> createState() => _TakeSurveyScreenState();
}

class _TakeSurveyScreenState extends State<TakeSurveyScreen>
    with TickerProviderStateMixin {
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _textControllers = {};

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadSurvey();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  void _loadSurvey() {
    context.read<SurveyBloc>().add(
      LoadSurveyDetail(projectId: widget.projectId, surveyId: widget.surveyId),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitSurvey(SurveyEntity survey) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final userName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous';

    for (final question in survey.questions) {
      if (question.required && !_hasAnswer(question.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseAnswerRequired),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    for (final entry in _textControllers.entries) {
      final text = entry.value.text.trim();
      if (text.isNotEmpty) {
        _answers[entry.key] = text;
      }
    }

    final response = SurveyResponseEntity(
      id: '',
      surveyId: widget.surveyId,
      respondentId: userId,
      respondentName: userName,
      submittedAt: DateTime.now(),
      answers: Map.from(_answers),
    );

    context.read<SurveyBloc>().add(
      SubmitSurveyResponse(
        projectId: widget.projectId,
        surveyId: widget.surveyId,
        response: response,
      ),
    );
  }

  bool _hasAnswer(String questionId) {
    if (_answers.containsKey(questionId)) {
      final answer = _answers[questionId];
      if (answer is List) return answer.isNotEmpty;
      if (answer is String) return answer.isNotEmpty;
      return answer != null;
    }
    if (_textControllers.containsKey(questionId)) {
      return _textControllers[questionId]!.text.trim().isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<SurveyBloc, SurveyState>(
      listener: (context, state) {
        if (state is ResponseSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(l10n.responseSubmitted),
                ],
              ),
              backgroundColor: AppColors.successDark,
            ),
          );
          context.pop();
        } else if (state is SurveyError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              state is SurveyDetailLoaded ? state.survey.title : l10n.survey,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark, size),
              _buildContent(context, state, l10n, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(bool isDark, Size size) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkSurface,
                      AppColors.darkPrimaryContainer.withValues(alpha: 0.15),
                      AppColors.darkSurface,
                    ]
                  : [
                      AppColors.brandCream,
                      AppColors.accentLavender.withValues(alpha: 0.1),
                      AppColors.brandCream,
                    ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    SurveyState state,
    AppLocalizations l10n,
    bool isDark,
  ) {
    if (state is SurveyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SurveyError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSurvey,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state is SurveyDetailLoaded) {
      return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.survey.questions.length,
                itemBuilder: (context, index) {
                  final question = state.survey.questions[index];
                  return _buildQuestionCard(
                    context,
                    question,
                    index + 1,
                    isDark,
                  );
                },
              ),
            ),
            _buildSubmitButton(context, state.survey, l10n),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildQuestionCard(
    BuildContext context,
    SurveyQuestionEntity question,
    int number,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$number',
                        style: TextStyle(
                          color: AppColors.brandPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.question,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (question.required)
                            Text(
                              '*',
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuestionInput(context, question, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionInput(
    BuildContext context,
    SurveyQuestionEntity question,
    bool isDark,
  ) {
    switch (question.type) {
      case SurveyQuestionType.radio:
        return _buildRadioOptions(question);
      case SurveyQuestionType.checkbox:
        return _buildCheckboxOptions(question);
      case SurveyQuestionType.text:
        return _buildTextInput(question, isDark);
      case SurveyQuestionType.rating:
        return _buildRatingInput(question);
    }
  }

  Widget _buildRadioOptions(SurveyQuestionEntity question) {
    return Column(
      children: question.options.map((option) {
        return RadioListTile<String>(
          value: option,
          groupValue: _answers[question.id] as String?,
          onChanged: (value) {
            setState(() => _answers[question.id] = value);
          },
          title: Text(option),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.brandPrimary,
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxOptions(SurveyQuestionEntity question) {
    final selected = (_answers[question.id] as List<String>?) ?? [];

    return Column(
      children: question.options.map((option) {
        return CheckboxListTile(
          value: selected.contains(option),
          onChanged: (checked) {
            setState(() {
              final list = List<String>.from(selected);
              if (checked == true) {
                list.add(option);
              } else {
                list.remove(option);
              }
              _answers[question.id] = list;
            });
          },
          title: Text(option),
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.brandPrimary,
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(SurveyQuestionEntity question, bool isDark) {
    _textControllers.putIfAbsent(question.id, () => TextEditingController());

    return TextField(
      controller: _textControllers[question.id],
      maxLines: 3,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.typeYourAnswer,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
      ),
    );
  }

  Widget _buildRatingInput(SurveyQuestionEntity question) {
    final rating = (_answers[question.id] as num?)?.toDouble() ?? 0.0;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const starSize = 40.0;
            const spacing = 8.0;
            const totalWidth = 5 * starSize + 4 * spacing;
            final startOffset = (constraints.maxWidth - totalWidth) / 2;

            return GestureDetector(
              onHorizontalDragStart: (details) {
                _updateRating(
                  details.localPosition.dx,
                  startOffset,
                  starSize,
                  spacing,
                  question.id,
                );
              },
              onHorizontalDragUpdate: (details) {
                _updateRating(
                  details.localPosition.dx,
                  startOffset,
                  starSize,
                  spacing,
                  question.id,
                );
              },
              onTapDown: (details) {
                _updateRating(
                  details.localPosition.dx,
                  startOffset,
                  starSize,
                  spacing,
                  question.id,
                );
              },
              child: Container(
                height: starSize + 16,
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final fillAmount = (rating - index).clamp(0.0, 1.0);

                    return Padding(
                      padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
                      child: SizedBox(
                        width: starSize,
                        height: starSize,
                        child: Stack(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: starSize,
                              color: Colors.grey.withValues(alpha: 0.25),
                            ),

                            ClipRect(
                              clipper: _HalfStarClipper(fillAmount),
                              child: Icon(
                                Icons.star_rounded,
                                size: starSize,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            rating > 0 ? '${rating.toStringAsFixed(1)} / 5.0' : '',
            key: ValueKey(rating),
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _updateRating(
    double localX,
    double startOffset,
    double starSize,
    double spacing,
    String questionId,
  ) {
    final adjustedX = localX - startOffset;
    if (adjustedX < 0) {
      setState(() => _answers[questionId] = 0.0);
      return;
    }

    double rating = 0.0;
    double position = 0.0;

    for (int i = 0; i < 5; i++) {
      final starStart = position;
      final starEnd = position + starSize;

      if (adjustedX >= starStart && adjustedX <= starEnd) {
        final starProgress = (adjustedX - starStart) / starSize;

        if (starProgress < 0.5) {
          rating = i + 0.5;
        } else {
          rating = (i + 1).toDouble();
        }
        break;
      } else if (adjustedX > starEnd) {
        rating = (i + 1).toDouble();
      }

      position = starEnd + spacing;
    }

    rating = rating.clamp(0.0, 5.0);
    setState(() => _answers[questionId] = rating);
  }

  Widget _buildSubmitButton(
    BuildContext context,
    SurveyEntity survey,
    AppLocalizations l10n,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandPrimary, AppColors.accentRose],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandPrimary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _submitSurvey(survey),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        l10n.submitResponse,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HalfStarClipper extends CustomClipper<Rect> {
  final double fraction;

  _HalfStarClipper(this.fraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }

  @override
  bool shouldReclip(_HalfStarClipper oldClipper) {
    return fraction != oldClipper.fraction;
  }
}
