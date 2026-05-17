import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai/domain/entities/prd_entity.dart';
import '../../features/ai/domain/entities/project_idea_entity.dart';
import '../../features/ai/presentation/bloc/project_idea_bloc.dart';
import '../../features/ai/presentation/pages/idea_generation_screen.dart';
import '../../features/ai/presentation/pages/idea_refinement_screen.dart';
import '../../features/ai_chat/domain/entities/chat_entities.dart';
import '../../features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import '../../features/ai_chat/presentation/pages/ai_chat_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/community/domain/entities/post_entity.dart';
import '../../features/community/presentation/bloc/comment_bloc.dart';
import '../../features/community/presentation/bloc/create_post_bloc.dart';
import '../../features/community/presentation/pages/community_feed_screen.dart';
import '../../features/community/presentation/pages/create_post_screen.dart';
import '../../features/community/presentation/pages/edit_post_screen.dart';
import '../../features/community/presentation/pages/post_detail_screen.dart';
import '../../features/home/presentation/bloc/workspace_bloc.dart';
import '../../features/home/presentation/pages/project_workspace_screen.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/notifications/presentation/pages/notification_center_screen.dart';
import '../../features/profile/domain/entities/profile_entity.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/skill_bloc.dart';
import '../../features/profile/presentation/pages/profile_edit_screen.dart';
import '../../features/profile/presentation/pages/profile_view_screen.dart';
import '../../features/profile/presentation/pages/skill_test_screen.dart';
import '../../features/project/presentation/bloc/project_creation_bloc.dart';
import '../../features/project/presentation/pages/project_creation_entry_screen.dart';
import '../../features/project/presentation/pages/project_creation_screen.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';
import '../../features/task/presentation/pages/task_detail_screen.dart';
import '../../features/core/presentation/main_shell.dart';
import '../../features/survey/presentation/bloc/survey_bloc.dart';
import '../../features/survey/presentation/pages/create_survey_screen.dart';
import '../../features/survey/presentation/pages/edit_survey_screen.dart';
import '../../features/survey/presentation/pages/survey_detail_screen.dart';
import '../../features/survey/presentation/pages/take_survey_screen.dart';
import '../../features/chat/presentation/pages/chat_selection_screen.dart';
import '../presentation/pages/splash_screen.dart';
import '../di/injection_container.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profileCreate = '/profile/create';
  static const String settings = '/settings';
  static const String projectDetails = '/project/:id';
  static const String chat = '/chat';
  static const String conversation = '/chat/:id';
  static const String calendar = '/calendar';
  static const String findPeople = '/find-people';
  static const String notifications = '/notifications';
  static const String notificationCenter = '/notifications';
  static const String projectCreationEntry = '/project/entry';
  static const String ideaRefinement = '/idea-refinement';
  static const String projectIdeas = '/project-ideas';
  static const String projectCreate = '/project/create';
  static const String aiChat = '/ai-chat';
  static const String community = '/community';
  static const String communityCreate = '/community/create';
  static const String communityPostDetail = '/community/post/:id';
  static const String communityPostEdit = '/community/post/:id/edit';
  static const String taskDetail = '/project/:projectId/task/:taskId';
  static const String skillTest = '/skill-test';
  static const String surveyCreate = '/project/:projectId/survey/create';
  static const String surveyDetail = '/project/:projectId/survey/:surveyId';
  static const String surveyTake = '/project/:projectId/survey/:surveyId/take';
  static const String surveyEdit = '/project/:projectId/survey/:surveyId/edit';
  static const String chatSelect = '/chat/select';
}

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    extraCodec: const AppExtraCodec(),
    observers: [routeObserver],
    refreshListenable: _AuthStateNotifier(),
    redirect: (context, state) {
      final authBloc = sl<AuthBloc>();
      final authState = authBloc.state;

      final matchedLocation = state.matchedLocation;
      final isSplash = matchedLocation == AppRoutes.splash;
      final isLoggingIn = matchedLocation == AppRoutes.login;
      final isRegistering = matchedLocation == AppRoutes.register;
      final isCreatingProfile = matchedLocation == AppRoutes.profileCreate;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      if (authState is AuthenticatedNeedsProfile) {
        final isSkillTest = matchedLocation == AppRoutes.skillTest;
        final isHome = matchedLocation == AppRoutes.home;
        if (!isCreatingProfile && !isSkillTest && !isHome) {
          return AppRoutes.profileCreate;
        }
        return null;
      }

      if (authState is Authenticated) {
        if (isSplash || isLoggingIn || isRegistering) {
          return AppRoutes.home;
        }

        return null;
      }

      if (authState is Unauthenticated || authState is AuthError) {
        if (isSplash) {
          return AppRoutes.login;
        }

        if (!isLoggingIn && !isRegistering) {
          return AppRoutes.login;
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const LoginScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider.value(
            value: sl<AuthBloc>(),
            child: const RegisterScreen(),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const MainShell(),
        ),
      ),

      GoRoute(
        path: AppRoutes.projectCreate,
        name: 'projectCreate',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final selectedIdea = extra?['idea'] as ProjectIdeaEntity?;
          final refinedIdea = extra?['refinedIdea'];
          final prd = extra?['prd'] as PrdEntity?;
          final userSkills = extra?['skills'] as List<String>? ?? [];
          final teamSize = extra?['teamSize'] as int? ?? 1;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProjectCreationBloc>(),
              child: ProjectCreationScreen(
                selectedIdea: selectedIdea,
                refinedIdea: refinedIdea,
                prd: prd,
                userSkills: userSkills,
                teamSize: teamSize,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.projectCreationEntry,
        name: 'projectCreationEntry',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final userSkills = extra['skills'] as List<String>? ?? [];
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ProjectCreationEntryScreen(userSkills: userSkills),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.projectDetails,
        name: 'projectDetails',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id'] ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<WorkspaceBloc>()),
                BlocProvider(
                  create: (_) {
                    final bloc = sl<ProfileBloc>();
                    final userId = FirebaseAuth.instance.currentUser?.uid;
                    if (userId != null) {
                      bloc.add(LoadProfile(userId: userId));
                    }
                    return bloc;
                  },
                ),
              ],
              child: ProjectWorkspaceScreen(projectId: projectId),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) {
          final profile = state.extra as ProfileEntity?;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProfileBloc>(),
              child: ProfileViewScreen(profile: profile),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileEdit,
        name: 'profileEdit',
        pageBuilder: (context, state) {
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          final existingProfile = state.extra as ProfileEntity?;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProfileBloc>(),
              child: ProfileEditScreen(
                userId: userId,
                existingProfile: existingProfile,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profileCreate,
        name: 'profileCreate',
        pageBuilder: (context, state) {
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProfileBloc>(),
              child: ProfileEditScreen(userId: userId),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const _PlaceholderScreen(title: 'Settings'),
        ),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const _PlaceholderScreen(title: 'Chat'),
        ),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        name: 'calendar',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const _PlaceholderScreen(title: 'Calendar'),
        ),
      ),
      GoRoute(
        path: AppRoutes.findPeople,
        name: 'findPeople',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const _PlaceholderScreen(title: 'Find People'),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: BlocProvider(
            create: (_) => sl<NotificationBloc>(),
            child: const NotificationCenterScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.ideaRefinement,
        name: 'ideaRefinement',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final userSkills = extra['skills'] as List<String>? ?? [];
          final teamSize = extra['teamSize'] as int? ?? 1;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProjectIdeaBloc>(),
              child: IdeaRefinementScreen(
                userSkills: userSkills,
                teamSize: teamSize,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.projectIdeas,
        name: 'projectIdeas',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final userSkills = extra['skills'] as List<String>? ?? [];
          final teamSize = extra['teamSize'] as int? ?? 1;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<ProjectIdeaBloc>(),
              child: IdeaGenerationScreen(
                userSkills: userSkills,
                teamSize: teamSize,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.community,
        name: 'community',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const CommunityFeedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.communityCreate,
        name: 'communityCreate',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<CreatePostBloc>(),
              child: CreatePostScreen(
                surveyId: extra['surveyId'] as String?,
                surveyProjectId: extra['surveyProjectId'] as String?,
                surveyTitle: extra['surveyTitle'] as String?,
                surveyDescription: extra['surveyDescription'] as String?,
                questionCount: extra['questionCount'] as int?,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.communityPostDetail,
        name: 'communityPostDetail',
        pageBuilder: (context, state) {
          final postId = state.pathParameters['id'] ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<CommentBloc>(),
              child: PostDetailScreen(postId: postId),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.communityPostEdit,
        name: 'communityPostEdit',
        pageBuilder: (context, state) {
          final post = state.extra as PostEntity;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: EditPostScreen(post: post),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.aiChat,
        name: 'aiChat',
        pageBuilder: (context, state) {
          final chatContext = state.extra as ChatContext;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<AIChatBloc>(),
              child: AIChatScreen(context: chatContext),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.taskDetail,
        name: 'taskDetail',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          final taskId = state.pathParameters['taskId'] ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<TaskBloc>(),
              child: TaskDetailScreen(projectId: projectId, taskId: taskId),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.skillTest,
        name: 'skillTest',
        pageBuilder: (context, state) {
          final skills = state.extra as List<String>? ?? [];
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<SkillBloc>(),
              child: SkillTestScreen(skillsToTest: skills),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.surveyCreate,
        name: 'surveyCreate',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final projectName = extra['projectName'] as String? ?? '';
          final projectDescription =
              extra['projectDescription'] as String? ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<SurveyBloc>(),
              child: CreateSurveyScreen(
                projectId: projectId,
                projectName: projectName,
                projectDescription: projectDescription,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surveyDetail,
        name: 'surveyDetail',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          final surveyId = state.pathParameters['surveyId'] ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<SurveyBloc>(),
              child: SurveyDetailScreen(
                projectId: projectId,
                surveyId: surveyId,
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surveyTake,
        name: 'surveyTake',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          final surveyId = state.pathParameters['surveyId'] ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<SurveyBloc>(),
              child: TakeSurveyScreen(projectId: projectId, surveyId: surveyId),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surveyEdit,
        name: 'surveyEdit',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['projectId'] ?? '';
          final surveyId = state.pathParameters['surveyId'] ?? '';
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) => sl<SurveyBloc>(),
              child: EditSurveyScreen(projectId: projectId, surveyId: surveyId),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatSelect,
        name: 'chatSelect',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ChatSelectionScreen(
              surveyId: extra['surveyId'] as String? ?? '',
              surveyProjectId: extra['surveyProjectId'] as String? ?? '',
              surveyTitle: extra['surveyTitle'] as String? ?? '',
              surveyDescription: extra['surveyDescription'] as String? ?? '',
              questionCount: extra['questionCount'] as int? ?? 0,
            ),
          );
        },
      ),
    ],
    errorPageBuilder: (context, state) => _buildPageWithTransition(
      context: context,
      state: state,
      child: _PlaceholderScreen(title: 'Error: ${state.error?.message}'),
    ),
  );

  static CustomTransitionPage<void> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    final authBloc = sl<AuthBloc>();
    authBloc.stream.listen((_) {
      notifyListeners();
    });
  }
}

class AppExtraCodec extends Codec<Object?, Object?> {
  const AppExtraCodec();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();
}

class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    if (input is Map<String, dynamic>) {
      if (input['__type'] == 'ChatContext') {
        return ChatContext(
          projectId: input['projectId'] as String,
          projectName: input['projectName'] as String,
          projectDescription: input['projectDescription'] as String,
          skills: (input['skills'] as List<dynamic>?)?.cast<String>() ?? [],
          taskId: input['taskId'] as String?,
          taskName: input['taskName'] as String?,
          taskDescription: input['taskDescription'] as String?,
          taskDetailedDescription: input['taskDetailedDescription'] as String?,
        );
      }
      return input;
    }
    return input;
  }
}

class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    if (input is ChatContext) {
      return {
        '__type': 'ChatContext',
        'projectId': input.projectId,
        'projectName': input.projectName,
        'projectDescription': input.projectDescription,
        'skills': input.skills,
        'taskId': input.taskId,
        'taskName': input.taskName,
        'taskDescription': input.taskDescription,
        'taskDetailedDescription': input.taskDetailedDescription,
      };
    }

    return input;
  }
}
