import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/survey_entity.dart';
import '../../domain/entities/survey_question_entity.dart';
import '../bloc/survey_bloc.dart';
import '../bloc/survey_event.dart';
import '../bloc/survey_state.dart';

class EditSurveyScreen extends StatefulWidget {
  final String projectId;
  final String surveyId;

  const EditSurveyScreen({
    super.key,
    required this.projectId,
    required this.surveyId,
  });

  @override
  State<EditSurveyScreen> createState() => _EditSurveyScreenState();
}

class _EditSurveyScreenState extends State<EditSurveyScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  SurveyEntity? _survey;
  List<_EditableQuestion> _questions = [];
  bool _isLoaded = false;

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

  void _populateFields(SurveyEntity survey) {
    if (_isLoaded) return;
    _isLoaded = true;

    _survey = survey;
    _titleController.text = survey.title;
    _descriptionController.text = survey.description;
    _questions = survey.questions
        .map((q) => _EditableQuestion.fromEntity(q))
        .toList();
    setState(() {});
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        _EditableQuestion(
          id: 'q${DateTime.now().millisecondsSinceEpoch}',
          type: SurveyQuestionType.radio,
          questionController: TextEditingController(text: ''),
          options: [TextEditingController(text: 'Option 1')],
          required: true,
          allowOther: false,
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      final question = _questions.removeAt(index);
      question.dispose();
    });
  }

  void _addOption(int questionIndex) {
    setState(() {
      _questions[questionIndex].options.add(
        TextEditingController(
          text: 'Option ${_questions[questionIndex].options.length + 1}',
        ),
      );
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    setState(() {
      final controller = _questions[questionIndex].options.removeAt(
        optionIndex,
      );
      controller.dispose();
    });
  }

  void _changeQuestionType(int index, SurveyQuestionType type) {
    setState(() {
      _questions[index].type = type;

      if ((type == SurveyQuestionType.radio ||
              type == SurveyQuestionType.checkbox) &&
          _questions[index].options.isEmpty) {
        _questions[index].options.add(TextEditingController(text: 'Option 1'));
      }
    });
  }

  void _saveSurvey() {
    if (_survey == null) return;

    final questions = _questions
        .map(
          (q) => SurveyQuestionEntity(
            id: q.id,
            type: q.type,
            question: q.questionController.text.trim(),
            options: q.options
                .map((c) => c.text.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
            required: q.required,
            allowOther: q.allowOther,
          ),
        )
        .toList();

    final updatedSurvey = SurveyEntity(
      id: _survey!.id,
      projectId: _survey!.projectId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectDescription: _survey!.projectDescription,
      createdBy: _survey!.createdBy,
      createdAt: _survey!.createdAt,
      updatedAt: DateTime.now(),
      status: SurveyStatus.active,
      responseCount: _survey!.responseCount,
      questions: questions,
    );

    context.read<SurveyBloc>().add(UpdateSurvey(survey: updatedSurvey));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _floatingController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<SurveyBloc, SurveyState>(
      listener: (context, state) {
        if (state is SurveyDetailLoaded && !_isLoaded) {
          _populateFields(state.survey);
        } else if (state is SurveyUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.surveyUpdated),
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
              l10n.editSurvey,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brandPrimary, AppColors.accentRose],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveSurvey,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        l10n.save,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              _buildAnimatedBackground(isDark, size),
              _buildContent(context, state, l10n, isDark),
            ],
          ),
          floatingActionButton: _isLoaded
              ? FloatingActionButton.extended(
                  onPressed: _addQuestion,
                  backgroundColor: AppColors.brandPrimary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    l10n.addQuestion,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
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
                      AppColors.accentRose.withValues(alpha: 0.1),
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
    if (state is SurveyLoading && !_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SurveyError && !_isLoaded) {
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

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(l10n.surveyTitle),
          const SizedBox(height: 8),
          _buildGlassTextField(_titleController, l10n.surveyTitleHint, isDark),
          const SizedBox(height: 20),

          _buildSectionHeader(l10n.surveyDescription),
          const SizedBox(height: 8),
          _buildGlassTextField(
            _descriptionController,
            l10n.surveyDescriptionHint,
            isDark,
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              _buildSectionHeader('${l10n.questions} (${_questions.length})'),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),

          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionEditor(context, index, question, l10n, isDark);
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGlassTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    int maxLines = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.9),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionEditor(
    BuildContext context,
    int index,
    _EditableQuestion question,
    AppLocalizations l10n,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.95),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.brandPrimary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.brandPrimary,
                            AppColors.accentRose,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.question,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _removeQuestion(index),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: l10n.delete,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: question.questionController,
                  decoration: InputDecoration(
                    hintText: l10n.enterQuestionText,
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
                      borderSide: BorderSide(
                        color: AppColors.brandPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  l10n.questionType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SurveyQuestionType.values.map((type) {
                    final isSelected = question.type == type;
                    return ChoiceChip(
                      label: Text(_getTypeLabel(type, l10n)),
                      selected: isSelected,
                      onSelected: (_) => _changeQuestionType(index, type),
                      selectedColor: AppColors.brandPrimary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    );
                  }).toList(),
                ),

                if (question.type == SurveyQuestionType.radio ||
                    question.type == SurveyQuestionType.checkbox) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        l10n.options,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _addOption(index),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.addOption),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...question.options.asMap().entries.map((optEntry) {
                    final optIndex = optEntry.key;
                    final optController = optEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            question.type == SurveyQuestionType.radio
                                ? Icons.radio_button_unchecked
                                : Icons.check_box_outline_blank,
                            size: 20,
                            color: AppColors.brandPrimary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: optController,
                              decoration: InputDecoration(
                                hintText: '${l10n.option} ${optIndex + 1}',
                                isDense: true,
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          if (question.options.length > 1)
                            IconButton(
                              onPressed: () => _removeOption(index, optIndex),
                              icon: Icon(
                                Icons.close,
                                size: 18,
                                color: theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(l10n.required, style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    Switch(
                      value: question.required,
                      onChanged: (value) {
                        setState(() => question.required = value);
                      },
                      activeColor: AppColors.brandPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeLabel(SurveyQuestionType type, AppLocalizations l10n) {
    switch (type) {
      case SurveyQuestionType.radio:
        return l10n.singleChoice;
      case SurveyQuestionType.checkbox:
        return l10n.multipleChoice;
      case SurveyQuestionType.text:
        return l10n.textAnswer;
      case SurveyQuestionType.rating:
        return l10n.starRating;
    }
  }
}

class _EditableQuestion {
  final String id;
  SurveyQuestionType type;
  final TextEditingController questionController;
  final List<TextEditingController> options;
  bool required;
  bool allowOther;

  _EditableQuestion({
    required this.id,
    required this.type,
    required this.questionController,
    required this.options,
    required this.required,
    required this.allowOther,
  });

  factory _EditableQuestion.fromEntity(SurveyQuestionEntity entity) {
    return _EditableQuestion(
      id: entity.id,
      type: entity.type,
      questionController: TextEditingController(text: entity.question),
      options: entity.options
          .map((o) => TextEditingController(text: o))
          .toList(),
      required: entity.required,
      allowOther: entity.allowOther,
    );
  }

  void dispose() {
    questionController.dispose();
    for (final c in options) {
      c.dispose();
    }
  }
}
