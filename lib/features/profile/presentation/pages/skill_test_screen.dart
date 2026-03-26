import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/skill_test_model.dart';
import '../bloc/skill_bloc.dart';

class SkillTestScreen extends StatefulWidget {
  final List<String> skillsToTest;

  const SkillTestScreen({super.key, required this.skillsToTest});

  @override
  State<SkillTestScreen> createState() => _SkillTestScreenState();
}

class _SkillTestScreenState extends State<SkillTestScreen> {
  final Map<String, String> _answers = {};
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    context.read<SkillBloc>().add(
      GenerateSkillTest(skillNames: widget.skillsToTest),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentQuestionIndex = index;
    });
  }

  void _nextQuestion(int totalQuestions) {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _goToQuestion(_currentQuestionIndex + 1);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _goToQuestion(_currentQuestionIndex - 1);
    }
  }

  void _submitTest() {
    context.read<SkillBloc>().add(SubmitSkillTest(answers: _answers));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.skillVerification,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitConfirmation(context);
          },
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(isDark),

          SafeArea(
            child: BlocConsumer<SkillBloc, SkillState>(
              listener: (context, state) {
                if (state is SkillTestEvaluated) {
                  _showResults(context, state);
                } else if (state is SkillError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SkillTestGenerating) {
                  return _buildLoadingState(isDark, l10n.generatingTest);
                }

                if (state is SkillTestEvaluating) {
                  return _buildLoadingState(isDark, l10n.evaluatingAnswers);
                }

                if (state is SkillTestReady) {
                  return _buildTestContent(state.test, isDark, l10n);
                }

                if (state is SkillError) {
                  return _buildErrorState(state.message, isDark, l10n);
                }

                return _buildLoadingState(isDark, l10n.loading);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  const Color(0xFF0f3460),
                ]
              : [
                  AppColors.brandPrimary.withValues(alpha: 0.1),
                  AppColors.accentRose.withValues(alpha: 0.05),
                  Colors.white,
                ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.brandPrimary),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.brandPrimaryDark,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestContent(
    SkillTestModel test,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final questions = test.questions;
    final currentQuestion = questions[_currentQuestionIndex];

    return Column(
      children: [
        _buildProgressIndicator(questions.length, isDark, l10n),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentQuestionIndex = index;
              });
            },
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _buildQuestionPage(question, isDark, l10n);
            },
          ),
        ),

        _buildNavigationButtons(
          totalQuestions: questions.length,
          currentQuestion: currentQuestion,
          isDark: isDark,
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(
    int totalQuestions,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.brandPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.questionProgress(
                        _currentQuestionIndex + 1,
                        totalQuestions,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : AppColors.brandPrimaryDark,
                      ),
                    ),
                    Text(
                      '${((_currentQuestionIndex + 1) / totalQuestions * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.brandPrimary,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPage(
    SkillTestQuestion question,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.brandPrimary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.brandPrimary.withValues(alpha: 0.2),
                        AppColors.accentRose.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question.skillName,
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      _getDifficultyIcon(question.difficulty),
                      size: 14,
                      color: _getDifficultyColor(question.difficulty),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      question.difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getDifficultyColor(question.difficulty),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                MarkdownWidget(
                  data: question.question,
                  shrinkWrap: true,
                  config: MarkdownConfig(
                    configs: [
                      PConfig(
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Colors.white
                              : AppColors.brandPrimaryDark,
                          height: 1.5,
                        ),
                      ),
                      H1Config(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.brandPrimaryDark,
                        ),
                      ),
                      H2Config(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.brandPrimaryDark,
                        ),
                      ),
                      CodeConfig(
                        style: TextStyle(
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.brandPrimary.withValues(alpha: 0.1),
                          color: isDark
                              ? AppColors.accentMint
                              : AppColors.brandPrimary,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      PreConfig(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.shade300,
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        textStyle: TextStyle(
                          color: isDark
                              ? AppColors.accentMint
                              : AppColors.brandPrimaryDark,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      ListConfig(
                        marker: (isOrdered, depth, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              isOrdered ? '${index + 1}.' : '•',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.brandPrimaryDark,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildAnswerInput(question, isDark, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerInput(
    SkillTestQuestion question,
    bool isDark,
    AppLocalizations l10n,
  ) {
    if (question.isMultipleChoice && question.options != null) {
      return _buildMultipleChoiceInput(question, isDark);
    } else {
      return _buildTextInput(question, isDark, l10n);
    }
  }

  Widget _buildMultipleChoiceInput(SkillTestQuestion question, bool isDark) {
    final selectedOption = _answers[question.id];

    return Column(
      children: question.options!.map((option) {
        final isSelected = selectedOption == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _answers[question.id] = option;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.brandPrimary, AppColors.accentRose],
                      )
                    : null,
                color: isSelected
                    ? null
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white54 : Colors.black45),
                        width: 2,
                      ),
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.brandPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.white
                                  : AppColors.brandPrimaryDark),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(
    SkillTestQuestion question,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isLongAnswer = question.isLongAnswer;

    return TextFormField(
      initialValue: _answers[question.id],
      maxLines: isLongAnswer ? 6 : 3,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.brandPrimaryDark,
      ),
      decoration: InputDecoration(
        hintText: isLongAnswer
            ? l10n.provideDetailedExplanation
            : l10n.enterYourAnswer,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
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
          borderSide: BorderSide(color: AppColors.brandPrimary),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _answers[question.id] = value;
        });
      },
    );
  }

  Widget _buildNavigationButtons({
    required int totalQuestions,
    required SkillTestQuestion currentQuestion,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    final isFirstQuestion = _currentQuestionIndex == 0;

    final currentAnswer = _answers[currentQuestion.id];
    final hasAnswer = currentAnswer != null && currentAnswer.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (!isFirstQuestion)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: OutlinedButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.previous),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white30
                              : AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

              Expanded(
                flex: isFirstQuestion ? 1 : 1,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: hasAnswer ? 1.0 : 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: hasAnswer
                            ? [AppColors.brandPrimary, AppColors.accentRose]
                            : [Colors.grey, Colors.grey.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: hasAnswer
                            ? (isLastQuestion
                                  ? _submitTest
                                  : () => _nextQuestion(totalQuestions))
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastQuestion ? l10n.submitTest : l10n.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastQuestion
                                    ? Icons.check_circle_outline
                                    : Icons.arrow_forward,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (!hasAnswer) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _answers[currentQuestion.id] = '__SKIPPED__';
                  });
                  if (isLastQuestion) {
                    _submitTest();
                  } else {
                    _nextQuestion(totalQuestions);
                  }
                },
                icon: Icon(
                  Icons.skip_next_rounded,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                label: Text(
                  l10n.skipQuestion,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.sentiment_satisfied_alt;
      case 'hard':
        return Icons.whatshot;
      default:
        return Icons.trending_up;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'hard':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _showExitConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final skillBloc = context.read<SkillBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitTestTitle),
        content: Text(l10n.exitTestMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.continueTest),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              skillBloc.add(const ResetSkillState());
              context.pop();
            },
            child: Text(l10n.exit, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResults(BuildContext context, SkillTestEvaluated state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SkillTestResultDialog(
        result: state.result,
        skillsTested: state.skillsTested,
        onDone: () {
          Navigator.pop(context);
          context.pop(state.result);
        },
      ),
    );
  }
}

class _SkillTestResultDialog extends StatelessWidget {
  final SkillTestResult result;
  final List<String> skillsTested;
  final VoidCallback onDone;

  const _SkillTestResultDialog({
    required this.result,
    required this.skillsTested,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentMint.withValues(alpha: 0.2),
                        AppColors.brandPrimary.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified,
                    size: 48,
                    color: AppColors.accentMint,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  AppLocalizations.of(context)!.testComplete,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                ...skillsTested.map((skill) {
                  final level = result.skillLevels[skill] ?? 'unknown';
                  final passed = result.passedSkills[skill] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          passed ? Icons.check_circle : Icons.cancel,
                          color: passed ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            skill,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            level.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                if (result.feedback.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.brandLightGray.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      result.feedback,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brandPrimary, AppColors.accentRose],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onDone,
                        borderRadius: BorderRadius.circular(14),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
