import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../bloc/chat_bloc.dart';
import 'connected_user_tile.dart';

void showConnectedPeopleSheet({
  required BuildContext context,
  required String userId,
  required ChatBloc chatBloc,
  required void Function(String otherUserId, String otherUserName)
  onUserSelected,
}) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  chatBloc.add(LoadConnectedUsers(userId: userId));

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return BlocProvider<ChatBloc>.value(
        value: chatBloc,
        child: _ConnectedPeopleBottomSheetContent(
          isDark: isDark,
          l10n: l10n,
          onUserSelected: (otherUserId, otherUserName) {
            Navigator.pop(sheetContext);
            onUserSelected(otherUserId, otherUserName);
          },
        ),
      );
    },
  );
}

class _ConnectedPeopleBottomSheetContent extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;
  final void Function(String otherUserId, String otherUserName) onUserSelected;

  const _ConnectedPeopleBottomSheetContent({
    required this.isDark,
    required this.l10n,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  _buildDragHandle(theme),

                  _buildHeader(theme),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),

                  Expanded(child: _buildUsersList(theme, scrollController)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.people_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.connectedPeople,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(ThemeData theme, ScrollController scrollController) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading || state is ConnectedUsersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(state.message),
              ],
            ),
          );
        }

        if (state is ConnectedUsersLoaded) {
          if (state.connectedUsers.isEmpty) {
            return _buildEmptyUsersState(theme);
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.connectedUsers.length,
            itemBuilder: (context, index) {
              final user = state.connectedUsers[index];
              return ConnectedUserTile(
                name: user.name,
                organization: user.organization,
                profilePicUrl: user.profilePicUrl,
                onTap: () => onUserSelected(user.userId, user.name),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildEmptyUsersState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(l10n.noConnectionsYet, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.noConnectionsMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
