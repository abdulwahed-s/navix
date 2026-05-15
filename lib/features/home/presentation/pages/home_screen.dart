import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home/glass_icon_button.dart';
import '../widgets/home/home_animated_background.dart';
import '../widgets/home/home_empty_state.dart';
import '../widgets/home/home_error_state.dart';
import '../widgets/home/home_floating_decorations.dart';
import '../widgets/home/home_gradient_fab.dart';
import '../widgets/home/home_loading_state.dart';
import '../widgets/home/home_project_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, RouteAware {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadProjects();
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

  void _loadProjects() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<HomeBloc>().add(LoadProjects(userId: userId));
    }
  }

  Future<void> _refreshProjects() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<HomeBloc>().add(RefreshProjects(userId: userId));
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
    _refreshProjects();
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
          l10n.myProjects,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GlassIconButton(
            icon: Icons.notifications_outlined,
            onPressed: () => context.push(AppRoutes.notificationCenter),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            icon: Icons.person_outline,
            onPressed: () => context.push(AppRoutes.profile),
            isDark: isDark,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          HomeAnimatedBackground(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),

          HomeFloatingDecorations(
            floatingAnimation: _floatingAnimation,
            isDark: isDark,
            size: size,
          ),

          SafeArea(
            child: BlocConsumer<HomeBloc, HomeState>(
              listener: (context, state) {
                if (state is ProjectsLoaded) {
                  _listAnimationController.forward(from: 0);
                }
              },
              builder: (context, state) {
                if (state is HomeLoading) {
                  return HomeLoadingState(
                    floatingAnimation: _floatingAnimation,
                  );
                }

                if (state is HomeEmpty) {
                  return HomeEmptyState(
                    floatingAnimation: _floatingAnimation,
                    isDark: isDark,
                  );
                }

                if (state is HomeError) {
                  return HomeErrorState(
                    message: state.message,
                    onRetry: _loadProjects,
                    isDark: isDark,
                  );
                }

                if (state is ProjectsLoaded) {
                  return HomeProjectList(
                    projects: state.projects,
                    listAnimationController: _listAnimationController,
                    isDark: isDark,
                    onRefresh: _refreshProjects,
                  );
                }

                return HomeLoadingState(floatingAnimation: _floatingAnimation);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: HomeGradientFab(
        label: l10n.createProject,
        onPressed: () {
          final profileState = context.read<ProfileBloc>().state;
          List<String> userSkills = [];

          if (profileState is ProfileLoaded) {
            userSkills = profileState.profile.skills
                .where((s) => s.isApproved)
                .map((s) => s.skillName)
                .toList();
          }

          context.push(
            AppRoutes.projectCreationEntry,
            extra: {'skills': userSkills},
          );
        },
      ),
    );
  }
}
