import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../calendar/presentation/bloc/calendar_bloc.dart';
import '../../calendar/presentation/pages/calendar_screen.dart';
import '../../chat/presentation/bloc/chat_bloc.dart';
import '../../chat/presentation/pages/chat_list_screen.dart';
import '../../community/presentation/bloc/community_feed_bloc.dart';
import '../../community/presentation/pages/community_feed_screen.dart';
import '../../find_people/presentation/bloc/user_discovery_bloc.dart';
import '../../find_people/presentation/pages/find_people_screen.dart';
import '../../find_projects/presentation/bloc/find_projects_bloc.dart';
import '../../find_projects/presentation/pages/find_projects_screen.dart';
import '../../home/presentation/bloc/home_bloc.dart';
import '../../home/presentation/pages/home_screen.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';
import '../../settings/presentation/bloc/settings_bloc.dart';
import '../../settings/presentation/pages/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index != _currentIndex) {
      _scaleController.forward().then((_) => _scaleController.reverse());
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navItems = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, l10n.home),
      _NavItem(
        Icons.calendar_today_outlined,
        Icons.calendar_today_rounded,
        l10n.calendar,
      ),
      _NavItem(
        Icons.people_outline_rounded,
        Icons.people_rounded,
        l10n.findPeople,
      ),
      _NavItem(
        Icons.work_outline_rounded,
        Icons.work_rounded,
        l10n.findProjects,
      ),
      _NavItem(
        Icons.chat_bubble_outline_rounded,
        Icons.chat_bubble_rounded,
        l10n.chat,
      ),
      _NavItem(Icons.forum_outlined, Icons.forum_rounded, l10n.community),
      _NavItem(Icons.settings_outlined, Icons.settings_rounded, l10n.settings),
    ];

    return BlocProvider(
      create: (_) {
        final bloc = sl<ProfileBloc>();
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          bloc.add(LoadProfile(userId: userId));
        }
        return bloc;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            BlocProvider(
              create: (_) => sl<HomeBloc>(),
              child: const HomeScreen(),
            ),

            BlocProvider(
              create: (_) => sl<CalendarBloc>(),
              child: const CalendarScreen(),
            ),

            BlocProvider.value(
              value: sl<UserDiscoveryBloc>(),
              child: const FindPeopleScreen(),
            ),

            BlocProvider(
              create: (_) => sl<FindProjectsBloc>(),
              child: const FindProjectsScreen(),
            ),

            BlocProvider(
              create: (_) => sl<ChatBloc>(),
              child: const ChatListScreen(),
            ),

            BlocProvider(
              create: (_) => sl<CommunityFeedBloc>(),
              child: const CommunityFeedScreen(),
            ),

            BlocProvider(
              create: (_) => sl<SettingsBloc>(),
              child: const SettingsScreen(),
            ),
          ],
        ),
        bottomNavigationBar: _buildGlassmorphicNavBar(navItems, theme, isDark),
      ),
    );
  }

  Widget _buildGlassmorphicNavBar(
    List<_NavItem> items,
    ThemeData theme,
    bool isDark,
  ) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  return _buildNavItem(items[index], index, theme, isDark);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index, ThemeData theme, bool isDark) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = isSelected && _scaleController.isAnimating
              ? _scaleAnimation.value
              : 1.0;

          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(isSelected ? 10 : 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.2,
                                ),
                                AppColors.accentGold.withValues(alpha: 0.1),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      size: isSelected ? 24 : 22,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),

                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isSelected ? 20 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                AppColors.accentGold,
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}
