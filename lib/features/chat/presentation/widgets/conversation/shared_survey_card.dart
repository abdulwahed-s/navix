import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../survey/domain/repositories/survey_repository.dart';
import '../../../domain/entities/message_entity.dart';

class SharedSurveyCard extends StatefulWidget {
  final MessageEntity message;

  final bool isMine;

  final bool isDark;

  final DateFormat timeFormat;

  const SharedSurveyCard({
    super.key,
    required this.message,
    required this.isMine,
    required this.isDark,
    required this.timeFormat,
  });

  @override
  State<SharedSurveyCard> createState() => _SharedSurveyCardState();
}

class _SharedSurveyCardState extends State<SharedSurveyCard> {
  late Future<bool> _hasRespondedFuture;
  final _surveyRepo = sl<SurveyRepository>();

  @override
  void initState() {
    super.initState();
    _checkUserResponse();
  }

  void _checkUserResponse() {
    final sharedSurvey = widget.message.sharedSurvey;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (sharedSurvey != null && currentUserId != null) {
      _hasRespondedFuture = _surveyRepo.hasUserResponded(
        sharedSurvey.projectId,
        sharedSurvey.surveyId,
        currentUserId,
      );
    } else {
      _hasRespondedFuture = Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharedSurvey = widget.message.sharedSurvey!;

    return FutureBuilder<bool>(
      future: _hasRespondedFuture,
      builder: (context, snapshot) {
        final hasResponded = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Align(
          alignment: widget.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              bottom: 8,
              left: widget.isMine ? 48 : 0,
              right: widget.isMine ? 0 : 48,
            ),
            constraints: const BoxConstraints(maxWidth: 300),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(widget.isMine ? 20 : 6),
                bottomRight: Radius.circular(widget.isMine ? 6 : 20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _buildGradient(hasResponded),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(widget.isMine ? 20 : 6),
                      bottomRight: Radius.circular(widget.isMine ? 6 : 20),
                    ),
                    border: widget.isMine
                        ? null
                        : Border.all(
                            color: hasResponded
                                ? AppColors.successDark.withValues(alpha: 0.2)
                                : theme.colorScheme.outline.withValues(
                                    alpha: 0.1,
                                  ),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isMine
                            ? (widget.isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.brandPrimary)
                                  .withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasResponded
                          ? null
                          : () => _navigateToSurvey(context, sharedSurvey),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(widget.isMine ? 20 : 6),
                        bottomRight: Radius.circular(widget.isMine ? 6 : 20),
                      ),
                      child: _buildContent(
                        theme,
                        sharedSurvey,
                        hasResponded,
                        isLoading,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient? _buildGradient(bool hasResponded) {
    if (!widget.isMine) {
      return hasResponded
          ? LinearGradient(
              colors: [
                AppColors.successDark.withValues(alpha: 0.1),
                AppColors.accentMint.withValues(alpha: 0.05),
              ],
            )
          : null;
    }

    if (hasResponded) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.successDark.withValues(alpha: 0.9),
          AppColors.accentMint.withValues(alpha: 0.9),
        ],
      );
    }

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: widget.isDark
          ? [
              AppColors.darkPrimary.withValues(alpha: 0.9),
              AppColors.accentRose.withValues(alpha: 0.9),
            ]
          : [
              AppColors.brandPrimary.withValues(alpha: 0.95),
              AppColors.brandPrimaryDark.withValues(alpha: 0.95),
            ],
    );
  }

  Widget _buildContent(
    ThemeData theme,
    SharedSurveyData sharedSurvey,
    bool hasResponded,
    bool isLoading,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasResponded
                      ? (widget.isMine
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.successDark.withValues(alpha: 0.15))
                      : (widget.isMine
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.brandPrimary.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasResponded
                      ? Icons.check_circle_outline
                      : Icons.poll_outlined,
                  size: 20,
                  color: _getIconColor(hasResponded),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasResponded ? l10n.completed : l10n.survey,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getTextColor(hasResponded),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sharedSurvey.questionCount > 0)
                    Text(
                      '${sharedSurvey.questionCount} ${l10n.questions}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: _getSecondaryTextColor(),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            sharedSurvey.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: widget.isMine
                  ? (widget.isDark ? AppColors.darkOnPrimary : Colors.white)
                  : theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (sharedSurvey.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              hasResponded
                  ? l10n.thankYouAlreadyCompleted
                  : sharedSurvey.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.isMine
                    ? (widget.isDark ? AppColors.darkOnPrimary : Colors.white)
                          .withValues(alpha: 0.85)
                    : theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),

          _buildFooter(theme, hasResponded, isLoading, l10n),
        ],
      ),
    );
  }

  Color _getIconColor(bool hasResponded) {
    if (widget.isMine) {
      return widget.isDark ? AppColors.darkOnPrimary : Colors.white;
    }
    return hasResponded ? AppColors.successDark : AppColors.brandPrimary;
  }

  Color _getTextColor(bool hasResponded) {
    if (widget.isMine) {
      return (widget.isDark ? AppColors.darkOnPrimary : Colors.white)
          .withValues(alpha: 0.8);
    }
    return hasResponded
        ? AppColors.successDark
        : Theme.of(context).colorScheme.onSurfaceVariant;
  }

  Color _getSecondaryTextColor() {
    if (widget.isMine) {
      return (widget.isDark ? AppColors.darkOnPrimary : Colors.white)
          .withValues(alpha: 0.6);
    }
    return Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.8);
  }

  Widget _buildFooter(
    ThemeData theme,
    bool hasResponded,
    bool isLoading,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.timeFormat.format(widget.message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: widget.isMine
                    ? (widget.isDark ? AppColors.darkOnPrimary : Colors.white)
                          .withValues(alpha: 0.7)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.isMine) ...[
              const SizedBox(width: 4),
              Icon(
                widget.message.status == MessageStatus.read
                    ? Icons.done_all_rounded
                    : Icons.done_rounded,
                size: 14,
                color: widget.message.status == MessageStatus.read
                    ? (widget.isDark
                          ? AppColors.accentMint
                          : AppColors.accentGold)
                    : (widget.isDark ? AppColors.darkOnPrimary : Colors.white)
                          .withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
        if (isLoading)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: hasResponded
                  ? (widget.isMine
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.successDark.withValues(alpha: 0.15))
                  : (widget.isMine
                        ? Colors.white.withValues(alpha: 0.2)
                        : AppColors.brandPrimary.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasResponded
                      ? Icons.check_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: _getButtonTextColor(hasResponded),
                ),
                const SizedBox(width: 4),
                Text(
                  hasResponded ? l10n.completed : l10n.takeSurvey,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getButtonTextColor(hasResponded),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getButtonTextColor(bool hasResponded) {
    if (widget.isMine) {
      return widget.isDark ? AppColors.darkOnPrimary : Colors.white;
    }
    return hasResponded ? AppColors.successDark : AppColors.brandPrimary;
  }

  void _navigateToSurvey(BuildContext context, SharedSurveyData sharedSurvey) {
    context.push(
      '/project/${sharedSurvey.projectId}/survey/${sharedSurvey.surveyId}/take',
    );
  }
}
