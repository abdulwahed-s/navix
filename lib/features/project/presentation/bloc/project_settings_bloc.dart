import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/assign_role_to_member_usecase.dart';
import '../../domain/usecases/get_project_roles_usecase.dart';
import 'project_settings_event.dart';
import 'project_settings_state.dart';

class ProjectSettingsBloc
    extends Bloc<ProjectSettingsEvent, ProjectSettingsState> {
  final GetProjectRolesUseCase getProjectRolesUseCase;
  final AssignRoleToMemberUseCase assignRoleToMemberUseCase;

  ProjectSettingsBloc({
    required this.getProjectRolesUseCase,
    required this.assignRoleToMemberUseCase,
  }) : super(const ProjectSettingsInitial()) {
    on<LoadProjectSettings>(_onLoadProjectSettings);
    on<AssignRoleToMember>(_onAssignRoleToMember);
    on<UnassignRole>(_onUnassignRole);
  }

  Future<void> _onLoadProjectSettings(
    LoadProjectSettings event,
    Emitter<ProjectSettingsState> emit,
  ) async {
    emit(const ProjectSettingsLoading());

    final result = await getProjectRolesUseCase(
      GetProjectRolesParams(projectId: event.projectId),
    );

    result.fold(
      (failure) => emit(
        ProjectSettingsError(
          message: failure.message,
          code: failure.code ?? 'unknown',
        ),
      ),
      (roles) => emit(ProjectSettingsLoaded(roles: roles)),
    );
  }

  Future<void> _onAssignRoleToMember(
    AssignRoleToMember event,
    Emitter<ProjectSettingsState> emit,
  ) async {
    emit(const ProjectSettingsLoading());

    final result = await assignRoleToMemberUseCase(
      AssignRoleToMemberParams(
        projectId: event.projectId,
        roleName: event.roleName,
        userId: event.userId,
        userName: event.userName,
      ),
    );

    await result.fold(
      (failure) async => emit(
        ProjectSettingsError(
          message: failure.message,
          code: failure.code ?? 'unknown',
        ),
      ),
      (_) async {
        final rolesResult = await getProjectRolesUseCase(
          GetProjectRolesParams(projectId: event.projectId),
        );

        rolesResult.fold(
          (failure) => emit(
            ProjectSettingsError(
              message: failure.message,
              code: failure.code ?? 'unknown',
            ),
          ),
          (roles) => emit(RoleAssignedSuccess(roles: roles)),
        );
      },
    );
  }

  Future<void> _onUnassignRole(
    UnassignRole event,
    Emitter<ProjectSettingsState> emit,
  ) async {
    emit(const ProjectSettingsLoading());

    final result = await assignRoleToMemberUseCase(
      AssignRoleToMemberParams(
        projectId: event.projectId,
        roleName: event.roleName,
        userId: '',
        userName: '',
      ),
    );

    await result.fold(
      (failure) async => emit(
        ProjectSettingsError(
          message: failure.message,
          code: failure.code ?? 'unknown',
        ),
      ),
      (_) async {
        final rolesResult = await getProjectRolesUseCase(
          GetProjectRolesParams(projectId: event.projectId),
        );

        rolesResult.fold(
          (failure) => emit(
            ProjectSettingsError(
              message: failure.message,
              code: failure.code ?? 'unknown',
            ),
          ),
          (roles) => emit(ProjectSettingsLoaded(roles: roles)),
        );
      },
    );
  }
}
