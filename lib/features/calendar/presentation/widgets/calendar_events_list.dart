import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_event_entity.dart';
import 'calendar_empty_state.dart';
import 'calendar_event_card.dart';

class CalendarEventsList extends StatelessWidget {
  final List<CalendarEventEntity> events;

  final DateTime selectedDate;

  final bool isDark;

  final AnimationController animationController;

  final double floatingAnimationValue;

  const CalendarEventsList({
    super.key,
    required this.events,
    required this.selectedDate,
    required this.isDark,
    required this.animationController,
    required this.floatingAnimationValue,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return CalendarEmptyState(animationValue: floatingAnimationValue);
    }

    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.event_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                dateFormat.format(selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final delay = index * 0.1;
                  final animationValue = Curves.easeOutCubic.transform(
                    (animationController.value - delay).clamp(0.0, 1.0),
                  );
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - animationValue)),
                    child: Opacity(
                      opacity: animationValue,
                      child: CalendarEventCard(
                        event: events[index],
                        isDark: isDark,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
