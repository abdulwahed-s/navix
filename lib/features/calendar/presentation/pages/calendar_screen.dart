import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../bloc/calendar_bloc.dart';
import '../widgets/calendar_background.dart';
import '../widgets/calendar_error_state.dart';
import '../widgets/calendar_events_list.dart';
import '../widgets/calendar_floating_decorations.dart';
import '../widgets/calendar_loading_state.dart';
import '../widgets/calendar_project_filter.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin, RouteAware {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadEvents();
  }

  void _initAnimations() {
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _loadEvents() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<CalendarBloc>().add(LoadEvents(userId: userId));
    }
  }

  void _refreshEvents() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<CalendarBloc>().add(RefreshEvents(userId: userId));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _refreshEvents();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _floatingController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.calendar,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {
                  context.read<CalendarBloc>().add(
                    SelectDate(date: DateTime.now()),
                  );
                  context.read<CalendarBloc>().add(
                    ChangeMonth(focusedDay: DateTime.now()),
                  );
                },
                icon: Icon(
                  Icons.today_rounded,
                  color: theme.colorScheme.primary,
                ),
                tooltip: l10n.today,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return CalendarBackground(
                isDark: isDark,
                size: size,
                animationValue: _floatingAnimation.value,
              );
            },
          ),

          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return CalendarFloatingDecorations(
                isDark: isDark,
                size: size,
                animationValue: _floatingAnimation.value,
              );
            },
          ),

          SafeArea(
            child: BlocConsumer<CalendarBloc, CalendarState>(
              listener: (context, state) {
                if (state is CalendarLoaded) {
                  _listAnimationController.forward(from: 0);
                }
              },
              builder: (context, state) {
                if (state is CalendarLoading) {
                  return const CalendarLoadingState();
                }

                if (state is CalendarError) {
                  return CalendarErrorState(message: state.message);
                }

                if (state is CalendarLoaded) {
                  return _buildCalendar(state, l10n, theme, isDark);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    CalendarLoaded state,
    AppLocalizations l10n,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      children: [
        if (state.projects.length > 1)
          CalendarProjectFilter(
            projects: state.projects,
            selectedProjectId: state.selectedProjectId,
            onProjectSelected: (projectId) {
              context.read<CalendarBloc>().add(
                FilterByProject(projectId: projectId),
              );
            },
            isDark: isDark,
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.9),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar<CalendarEventEntity>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: state.focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(day, state.selectedDate),
                  eventLoader: (day) => state.getEventsForDay(day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (selectedDay, focusedDay) {
                    context.read<CalendarBloc>().add(
                      SelectDate(date: selectedDay),
                    );
                    context.read<CalendarBloc>().add(
                      ChangeMonth(focusedDay: focusedDay),
                    );
                    _listAnimationController.forward(from: 0);
                  },
                  onPageChanged: (focusedDay) {
                    context.read<CalendarBloc>().add(
                      ChangeMonth(focusedDay: focusedDay),
                    );
                  },
                  calendarStyle: CalendarStyle(
                    cellMargin: const EdgeInsets.all(4),
                    todayDecoration: BoxDecoration(
                      color: isDark
                          ? AppColors.accentMint.withValues(alpha: 0.3)
                          : AppColors.accentMint.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: isDark ? Colors.white : AppColors.successDark,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkPrimary, AppColors.accentRose]
                            : [
                                AppColors.brandPrimary,
                                AppColors.brandPrimaryDark,
                              ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.brandPrimary)
                                  .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    selectedTextStyle: TextStyle(
                      color: isDark ? AppColors.darkOnPrimary : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    weekendTextStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    outsideTextStyle: TextStyle(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    markerSize: 6,
                    markersMaxCount: 3,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    rightChevronIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                    weekendStyle: theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return null;
                      return Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: events.take(3).map((event) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: _getEventColor(event.type, isDark),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getEventColor(
                                      event.type,
                                      isDark,
                                    ).withValues(alpha: 0.4),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: CalendarEventsList(
            events: state.selectedDateEvents,
            selectedDate: state.selectedDate,
            isDark: isDark,
            animationController: _listAnimationController,
            floatingAnimationValue: _floatingAnimation.value,
          ),
        ),
      ],
    );
  }

  Color _getEventColor(CalendarEventType type, bool isDark) {
    switch (type) {
      case CalendarEventType.milestoneDeadline:
        return AppColors.riskHigh;
      case CalendarEventType.taskDeadline:
        return isDark ? AppColors.accentLavender : AppColors.brandPrimary;
      case CalendarEventType.meeting:
        return AppColors.accentMint;
    }
  }
}
