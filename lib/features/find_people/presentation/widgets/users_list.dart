import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/connection_status.dart';
import 'connection_message_dialog.dart';
import 'find_people_empty_state.dart';
import 'user_card.dart';

class UsersList extends StatelessWidget {
  final List<ProfileEntity> users;

  final Map<String, ConnectionStatus> connectionStatuses;

  final bool isDark;

  final AnimationController listAnimationController;

  final Animation<double> floatingAnimation;

  final void Function(String userId, String? message) onConnect;

  final void Function(String userId) onCancelConnection;

  final void Function(String userId) onRemoveConnection;

  const UsersList({
    super.key,
    required this.users,
    required this.connectionStatuses,
    required this.isDark,
    required this.listAnimationController,
    required this.floatingAnimation,
    required this.onConnect,
    required this.onCancelConnection,
    required this.onRemoveConnection,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (users.isEmpty) {
      return FindPeopleEmptyState(floatingAnimation: floatingAnimation);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            l10n.usersFound(users.length),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final connectionStatus =
                  connectionStatuses[user.userId] ?? ConnectionStatus.none;

              return AnimatedBuilder(
                animation: listAnimationController,
                builder: (context, child) {
                  final delay = index * 0.08;
                  final animationValue = Curves.easeOutCubic.transform(
                    (listAnimationController.value - delay).clamp(0.0, 1.0),
                  );
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - animationValue)),
                    child: Opacity(
                      opacity: animationValue,
                      child: UserCard(
                        user: user,
                        connectionStatus: connectionStatus,
                        isDark: isDark,
                        skillColorIndex: index,
                        onConnect: () async {
                          final result = await ConnectionMessageDialog.show(
                            context,
                            user.name,
                          );

                          if (result != null && context.mounted) {
                            final message = result.isEmpty ? null : result;
                            onConnect(user.userId, message);
                          }
                        },
                        onCancelConnection: () =>
                            onCancelConnection(user.userId),
                        onRemoveConnection: () =>
                            onRemoveConnection(user.userId),
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
