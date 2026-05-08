import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navix/l10n/app_localizations.dart';
import '../bloc/user_discovery_bloc.dart';
import '../widgets/active_filters_list.dart';
import '../widgets/animated_background.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/find_people_error_state.dart';
import '../widgets/find_people_loading_state.dart';
import '../widgets/find_people_search_bar.dart';
import '../widgets/floating_decorations.dart';
import '../widgets/users_list.dart';

class FindPeopleScreen extends StatefulWidget {
  const FindPeopleScreen({super.key});

  @override
  State<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends State<FindPeopleScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _selectedSkills = <String>[];

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAnimations();
    context.read<UserDiscoveryBloc>().add(const LoadInitialUsers());
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
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _floatingController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<UserDiscoveryBloc>().add(const LoadInitialUsers());
    }
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
          l10n.findPeople,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showFilterSheet(context, l10n, isDark),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Badge(
                  isLabelVisible: _selectedSkills.isNotEmpty,
                  label: Text('${_selectedSkills.length}'),
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.tune_rounded,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              tooltip: l10n.filters,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),

          FloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),

          SafeArea(
            child: Column(
              children: [
                FindPeopleSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  isDark: isDark,
                  onChanged: (query) {
                    setState(() {});
                    context.read<UserDiscoveryBloc>().add(
                      SearchUsers(query: query),
                    );
                  },
                  onClear: () {
                    _searchController.clear();
                    context.read<UserDiscoveryBloc>().add(
                      const SearchUsers(query: ''),
                    );
                    setState(() {});
                  },
                ),

                BlocBuilder<UserDiscoveryBloc, UserDiscoveryState>(
                  builder: (context, state) {
                    if (state is UserDiscoveryLoaded &&
                        state.activeFilters.isNotEmpty) {
                      return ActiveFiltersList(
                        activeFilters: state.activeFilters,
                        onRemoveFilter: (skill) {
                          final newFilters = List<String>.from(
                            state.activeFilters,
                          )..remove(skill);
                          context.read<UserDiscoveryBloc>().add(
                            ApplyFilters(skills: newFilters),
                          );
                          _selectedSkills.remove(skill);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                Expanded(
                  child: BlocConsumer<UserDiscoveryBloc, UserDiscoveryState>(
                    listener: (context, state) {
                      if (state is UserDiscoveryLoaded) {
                        _listAnimationController.forward(from: 0);
                      }
                    },
                    builder: (context, state) {
                      if (state is UserDiscoveryLoading) {
                        return const FindPeopleLoadingState();
                      }

                      if (state is UserDiscoveryError) {
                        return FindPeopleErrorState(message: state.message);
                      }

                      if (state is UserDiscoveryLoaded) {
                        return UsersList(
                          users: state.users,
                          connectionStatuses: state.connectionStatuses,
                          isDark: isDark,
                          listAnimationController: _listAnimationController,
                          floatingAnimation: _floatingAnimation,
                          onConnect: (userId, message) {
                            context.read<UserDiscoveryBloc>().add(
                              SendConnection(userId: userId, message: message),
                            );
                          },
                          onCancelConnection: (userId) {
                            context.read<UserDiscoveryBloc>().add(
                              CancelConnection(userId: userId),
                            );
                          },
                          onRemoveConnection: (userId) {
                            context.read<UserDiscoveryBloc>().add(
                              RemoveConnection(userId: userId),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showFilterBottomSheet(
      context: context,
      selectedSkills: _selectedSkills,
      onApply: (skills) {
        _selectedSkills
          ..clear()
          ..addAll(skills);
        this.context.read<UserDiscoveryBloc>().add(
          ApplyFilters(skills: List.from(_selectedSkills)),
        );
      },
    );
  }
}
