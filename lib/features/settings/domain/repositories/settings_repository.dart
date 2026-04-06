import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, UserSettingsEntity>> getSettings(String userId);

  Future<Either<Failure, void>> updateSettings({
    required String userId,
    required UserSettingsEntity settings,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Either<Failure, void>> deleteAccount(String userId);
}
