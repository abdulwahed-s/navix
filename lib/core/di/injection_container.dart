import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../features/ai/data/datasources/ai_remote_datasource.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/domain/usecases/generate_prd_usecase.dart';
import '../../features/ai/domain/usecases/generate_project_ideas_usecase.dart';
import '../../features/ai/presentation/bloc/project_idea_bloc.dart';
import '../../features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import '../../features/ai_chat/data/repositories/ai_chat_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/ai_chat_repository.dart';
import '../../features/ai_chat/domain/usecases/chat_with_ai_usecase.dart';
import '../../features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/community/data/datasources/community_remote_datasource.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/usecases/add_comment_usecase.dart';
import '../../features/community/domain/usecases/create_post_usecase.dart';
import '../../features/community/domain/usecases/delete_comment_usecase.dart';
import '../../features/community/domain/usecases/delete_post_usecase.dart';
import '../../features/community/domain/usecases/get_post_comments_usecase.dart';
import '../../features/community/domain/usecases/get_posts_usecase.dart';
import '../../features/community/domain/usecases/get_user_posts_usecase.dart';
import '../../features/community/domain/usecases/reply_to_comment_usecase.dart';
import '../../features/community/domain/usecases/update_comment_usecase.dart';
import '../../features/community/domain/usecases/update_post_usecase.dart';
import '../../features/community/domain/usecases/upload_post_image_usecase.dart';
import '../../features/community/domain/usecases/vote_comment_usecase.dart';
import '../../features/community/domain/usecases/vote_post_usecase.dart';
import '../../features/community/domain/usecases/watch_post_comments_usecase.dart';
import '../../features/community/domain/usecases/watch_posts_usecase.dart';
import '../../features/community/presentation/bloc/comment_bloc.dart';
import '../../features/community/presentation/bloc/community_feed_bloc.dart';
import '../../features/community/presentation/bloc/create_post_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/workspace_bloc.dart';
import '../../features/prediction/data/datasources/prediction_remote_datasource.dart';
import '../../features/prediction/data/repositories/prediction_repository_impl.dart';
import '../../features/prediction/domain/repositories/prediction_repository.dart';
import '../../features/prediction/domain/usecases/analyze_project_health_usecase.dart';
import '../../features/prediction/presentation/bloc/prediction_bloc.dart';
import '../../features/task/data/repositories/task_repository_impl.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/usecases/add_task_comment_usecase.dart';
import '../../features/task/domain/usecases/update_task_status_usecase.dart';
import '../../features/task/presentation/bloc/task_bloc.dart';
import '../../features/calendar/data/repositories/calendar_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/domain/usecases/get_all_events_usecase.dart';
import '../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../features/find_projects/data/repositories/find_projects_repository_impl.dart';
import '../../features/find_projects/domain/repositories/find_projects_repository.dart';
import '../../features/find_projects/domain/usecases/apply_to_project_usecase.dart';
import '../../features/find_projects/domain/usecases/get_join_requests_usecase.dart';
import '../../features/find_projects/domain/usecases/get_project_listings_usecase.dart';
import '../../features/find_projects/domain/usecases/publish_project_listing_usecase.dart';
import '../../features/find_projects/domain/usecases/remove_project_listing_usecase.dart';
import '../../features/find_projects/domain/usecases/respond_to_join_request_usecase.dart';
import '../../features/find_projects/presentation/bloc/find_projects_bloc.dart';
import '../../features/find_people/data/repositories/user_discovery_repository_impl.dart';
import '../../features/find_people/domain/repositories/user_discovery_repository.dart';
import '../../features/find_people/domain/usecases/search_users_usecase.dart';
import '../../features/find_people/presentation/bloc/user_discovery_bloc.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../theme/cubit/theme_cubit.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/team/data/repositories/team_repository_impl.dart';
import '../../features/team/domain/repositories/team_repository.dart';
import '../../features/team/domain/usecases/accept_invitation_usecase.dart';
import '../../features/team/domain/usecases/change_member_role_usecase.dart';
import '../../features/team/domain/usecases/decline_invitation_usecase.dart';
import '../../features/team/domain/usecases/get_pending_invitations_usecase.dart';
import '../../features/team/domain/usecases/get_team_members_usecase.dart';
import '../../features/team/domain/usecases/remove_member_usecase.dart';
import '../../features/team/domain/usecases/send_invitation_usecase.dart';
import '../../features/team/presentation/bloc/team_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/create_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_profile_picture_usecase.dart';
import '../../features/profile/domain/usecases/add_skill_usecase.dart';
import '../../features/profile/domain/usecases/generate_skill_test_usecase.dart';
import '../../features/profile/domain/usecases/evaluate_skill_test_usecase.dart';
import '../../features/profile/data/datasources/skill_remote_datasource.dart';
import '../../features/profile/data/repositories/skill_repository_impl.dart';
import '../../features/profile/domain/repositories/skill_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/skill_bloc.dart';
import '../../features/project/data/datasources/project_remote_datasource.dart';
import '../../features/project/data/datasources/roadmap_remote_datasource.dart';
import '../../features/project/data/repositories/project_repository_impl.dart';
import '../../features/project/data/repositories/roadmap_repository_impl.dart';
import '../../features/project/domain/repositories/project_repository.dart';
import '../../features/project/domain/usecases/assign_role_to_member_usecase.dart';
import '../../features/project/domain/usecases/create_project_usecase.dart';
import '../../features/project/domain/usecases/generate_roadmap_usecase.dart';
import '../../features/project/domain/usecases/get_project_roles_usecase.dart';
import '../../features/project/domain/usecases/get_user_projects_usecase.dart';
import '../../features/project/presentation/bloc/project_creation_bloc.dart';
import '../../features/project_supervisor/data/datasources/project_supervisor_remote_datasource.dart';
import '../../features/project_supervisor/data/datasources/prd_editor_remote_datasource.dart';
import '../../features/project_supervisor/data/repositories/project_supervisor_repository_impl.dart';
import '../../features/project_supervisor/data/repositories/prd_editor_repository_impl.dart';
import '../../features/project_supervisor/domain/repositories/project_supervisor_repository.dart';
import '../../features/project_supervisor/domain/repositories/prd_editor_repository.dart';
import '../../features/project_supervisor/domain/usecases/chat_with_supervisor_usecase.dart';
import '../../features/project_supervisor/domain/usecases/execute_ai_action_usecase.dart';
import '../../features/project_supervisor/domain/usecases/edit_prd_with_ai_usecase.dart';
import '../../features/project_supervisor/presentation/bloc/project_supervisor_bloc.dart';
import '../../features/project_supervisor/presentation/bloc/prd_editor_bloc.dart';
import '../../features/survey/data/datasources/survey_remote_datasource.dart';
import '../../features/survey/data/repositories/survey_repository_impl.dart';
import '../../features/survey/domain/repositories/survey_repository.dart';
import '../../features/survey/domain/usecases/create_survey_usecase.dart';
import '../../features/survey/domain/usecases/delete_survey_usecase.dart';
import '../../features/survey/domain/usecases/generate_survey_usecase.dart';
import '../../features/survey/domain/usecases/get_responses_usecase.dart';
import '../../features/survey/domain/usecases/get_survey_by_id_usecase.dart';
import '../../features/survey/domain/usecases/get_surveys_usecase.dart';
import '../../features/survey/domain/usecases/submit_response_usecase.dart';
import '../../features/survey/domain/usecases/update_survey_usecase.dart';
import '../../features/survey/domain/usecases/watch_surveys_usecase.dart';
import '../../features/survey/presentation/bloc/survey_bloc.dart';
import '../constants/api_constants.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl()),
  );

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.ollamaBaseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 300),
        receiveTimeout: const Duration(seconds: 300),
      ),
    );
    return dio;
  });

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  _initAuthFeature();

  _initProfileFeature();

  _initAIFeature();

  _initProjectFeature();

  _initHomeFeature();

  _initPredictionFeature();

  _initTaskFeature();

  _initCalendarFeature();

  _initFindPeopleFeature();

  _initFindProjectsFeature();

  _initChatFeature();

  _initSettingsFeature();

  _initNotificationsFeature();

  _initTeamFeature();

  _initAIChatFeature();

  _initCommunityFeature();

  _initProjectSupervisorFeature();

  _initSurveyFeature();
}

void _initAuthFeature() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
      profileRepository: sl(),
    ),
  );
}

void _initProfileFeature() {
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton<SkillRemoteDataSource>(
    () => SkillRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<SkillRepository>(
    () => SkillRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfilePictureUseCase(sl()));
  sl.registerLazySingleton(() => AddSkillUseCase(sl()));
  sl.registerLazySingleton(() => GenerateSkillTestUseCase(sl()));
  sl.registerLazySingleton(() => EvaluateSkillTestUseCase(sl()));

  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      createProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      uploadProfilePictureUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SkillBloc(
      addSkillUseCase: sl(),
      generateSkillTestUseCase: sl(),
      evaluateSkillTestUseCase: sl(),
    ),
  );
}

void _initAIFeature() {
  sl.registerLazySingleton<AIRemoteDataSource>(
    () => AIRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AIRepository>(
    () => AIRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GenerateProjectIdeasUseCase(sl()));
  sl.registerLazySingleton(() => GeneratePrdUseCase(sl()));

  sl.registerFactory(
    () => ProjectIdeaBloc(
      generateProjectIdeasUseCase: sl(),
      generatePrdUseCase: sl(),
      aiRepository: sl(),
    ),
  );
}

void _initProjectFeature() {
  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<RoadmapRemoteDataSource>(
    () => RoadmapRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<RoadmapRepository>(
    () => RoadmapRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => CreateProjectUseCase(sl()));
  sl.registerLazySingleton(() => GenerateRoadmapUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetProjectRolesUseCase(sl()));
  sl.registerLazySingleton(() => AssignRoleToMemberUseCase(sl()));

  sl.registerFactory(
    () => ProjectCreationBloc(
      generateRoadmapUseCase: sl(),
      createProjectUseCase: sl(),
    ),
  );
}

void _initHomeFeature() {
  sl.registerFactory(() => HomeBloc(getUserProjectsUseCase: sl()));
  sl.registerFactory(
    () => WorkspaceBloc(projectRepository: sl(), profileRepository: sl()),
  );
}

void _initPredictionFeature() {
  sl.registerLazySingleton<PredictionRemoteDataSource>(
    () => PredictionRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<PredictionRepository>(
    () => PredictionRepositoryImpl(
      remoteDataSource: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton(() => AnalyzeProjectHealthUseCase(sl()));

  sl.registerFactory(
    () => PredictionBloc(
      analyzeProjectHealthUseCase: sl(),
      predictionRepository: sl(),
    ),
  );
}

void _initTaskFeature() {
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => UpdateTaskStatusUseCase(sl()));
  sl.registerLazySingleton(() => AddTaskCommentUseCase(sl()));

  sl.registerFactory(
    () => TaskBloc(
      taskRepository: sl(),
      updateTaskStatusUseCase: sl(),
      addTaskCommentUseCase: sl(),
    ),
  );
}

void _initCalendarFeature() {
  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton(() => GetAllEventsUseCase(sl()));

  sl.registerFactory(() => CalendarBloc(getAllEventsUseCase: sl()));
}

void _initFindPeopleFeature() {
  sl.registerLazySingleton<UserDiscoveryRepository>(
    () => UserDiscoveryRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton(() => SearchUsersUseCase(sl()));

  sl.registerLazySingleton(
    () => UserDiscoveryBloc(repository: sl(), searchUsersUseCase: sl()),
  );
}

void _initFindProjectsFeature() {
  sl.registerLazySingleton<FindProjectsRepository>(
    () => FindProjectsRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton(() => GetProjectListingsUseCase(sl()));
  sl.registerLazySingleton(() => PublishProjectListingUseCase(sl()));
  sl.registerLazySingleton(() => RemoveProjectListingUseCase(sl()));
  sl.registerLazySingleton(() => ApplyToProjectUseCase(sl()));
  sl.registerLazySingleton(() => GetJoinRequestsUseCase(sl()));
  sl.registerLazySingleton(() => RespondToJoinRequestUseCase(sl()));

  sl.registerFactory(() => FindProjectsBloc(repository: sl()));
}

void _initChatFeature() {
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );

  sl.registerFactory(() => ChatBloc(repository: sl()));
}

void _initSettingsFeature() {
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory(
    () => SettingsBloc(repository: sl(), firebaseAuth: sl(), themeCubit: sl()),
  );
}

void _initNotificationsFeature() {
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(firestore: sl(), networkInfo: sl()),
  );

  sl.registerFactory(() => NotificationBloc(repository: sl()));
}

void _initTeamFeature() {
  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(
      firestore: sl(),
      networkInfo: sl(),
      notificationRepository: sl(),
    ),
  );

  sl.registerLazySingleton(() => SendInvitationUseCase(sl()));
  sl.registerLazySingleton(() => AcceptInvitationUseCase(sl()));
  sl.registerLazySingleton(() => DeclineInvitationUseCase(sl()));
  sl.registerLazySingleton(() => RemoveMemberUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingInvitationsUseCase(sl()));
  sl.registerLazySingleton(() => ChangeMemberRoleUseCase(sl()));
  sl.registerLazySingleton(() => GetTeamMembersUseCase(sl()));

  sl.registerFactory(() => TeamBloc(repository: sl()));
}

void _initAIChatFeature() {
  sl.registerLazySingleton<AIChatRemoteDataSource>(
    () => AIChatRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AIChatRepository>(
    () => AIChatRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => ChatWithAIUseCase(sl()));

  sl.registerFactory(() => AIChatBloc(chatWithAIUseCase: sl()));
}

void _initCommunityFeature() {
  sl.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );

  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePostUseCase(sl()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton(() => VotePostUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));
  sl.registerLazySingleton(() => ReplyToCommentUseCase(sl()));
  sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
  sl.registerLazySingleton(() => VoteCommentUseCase(sl()));
  sl.registerLazySingleton(() => UploadPostImageUseCase(sl()));
  sl.registerLazySingleton(() => GetUserPostsUseCase(sl()));
  sl.registerLazySingleton(() => WatchPostsUseCase(sl()));
  sl.registerLazySingleton(() => WatchPostCommentsUseCase(sl()));

  sl.registerFactory(
    () => CommunityFeedBloc(
      getPostsUseCase: sl(),
      votePostUseCase: sl(),
      watchPostsUseCase: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => CreatePostBloc(createPostUseCase: sl(), uploadPostImageUseCase: sl()),
  );

  sl.registerFactory(
    () => CommentBloc(
      getPostCommentsUseCase: sl(),
      addCommentUseCase: sl(),
      replyToCommentUseCase: sl(),
      voteCommentUseCase: sl(),
      watchPostCommentsUseCase: sl(),
    ),
  );
}

void _initProjectSupervisorFeature() {
  sl.registerLazySingleton<ProjectSupervisorRemoteDataSource>(
    () => ProjectSupervisorRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PrdEditorRemoteDataSource>(
    () => PrdEditorRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProjectSupervisorRepository>(
    () => ProjectSupervisorRepositoryImpl(
      remoteDataSource: sl(),
      firestore: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<PrdEditorRepository>(
    () => PrdEditorRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => ChatWithSupervisorUseCase(sl()));
  sl.registerLazySingleton(() => ExecuteAIActionUseCase(sl()));
  sl.registerLazySingleton(() => EditPrdWithAIUseCase(sl()));

  sl.registerFactory(
    () => ProjectSupervisorBloc(
      chatWithSupervisorUseCase: sl(),
      executeAIActionUseCase: sl(),
    ),
  );
  sl.registerFactory(() => PrdEditorBloc(editPrdWithAIUseCase: sl()));
}

void _initSurveyFeature() {
  sl.registerLazySingleton<SurveyRemoteDatasource>(
    () => SurveyRemoteDatasourceImpl(),
  );

  sl.registerLazySingleton<SurveyRepository>(
    () => SurveyRepositoryImpl(remoteDatasource: sl(), dio: sl()),
  );

  sl.registerLazySingleton(() => CreateSurveyUseCase(sl()));
  sl.registerLazySingleton(() => GetSurveysUseCase(sl()));
  sl.registerLazySingleton(() => GetSurveyByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSurveyUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSurveyUseCase(sl()));
  sl.registerLazySingleton(() => SubmitSurveyResponseUseCase(sl()));
  sl.registerLazySingleton(() => GetSurveyResponsesUseCase(sl()));
  sl.registerLazySingleton(() => GenerateSurveyWithAIUseCase(sl()));
  sl.registerLazySingleton(() => WatchSurveysUseCase(sl()));

  sl.registerFactory(
    () => SurveyBloc(
      getSurveysUseCase: sl(),
      getSurveyByIdUseCase: sl(),
      createSurveyUseCase: sl(),
      updateSurveyUseCase: sl(),
      deleteSurveyUseCase: sl(),
      getResponsesUseCase: sl(),
      submitResponseUseCase: sl(),
      generateSurveyUseCase: sl(),
      watchSurveysUseCase: sl(),
    ),
  );
}
