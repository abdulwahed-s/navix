import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final NetworkInfo networkInfo;

  SettingsRepositoryImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserSettingsEntity>> getSettings(String userId) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (!doc.exists) {
        return Right(UserSettingsEntity.defaults());
      }

      final data = doc.data() ?? {};
      return Right(
        UserSettingsEntity(
          notificationPreferences: Map<String, bool>.from(
            data['notificationPreferences'] ?? {},
          ),
          privacySettings: Map<String, String>.from(
            data['privacySettings'] ?? {},
          ),
          themeMode: data['themeMode'] as String? ?? 'system',
          language: data['language'] as String? ?? 'en',
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get settings: $e',
          code: 'settings-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings({
    required String userId,
    required UserSettingsEntity settings,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({
            'notificationPreferences': settings.notificationPreferences,
            'privacySettings': settings.privacySettings,
            'themeMode': settings.themeMode,
            'language': settings.language,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to update settings: $e',
          code: 'settings-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return const Left(
          AuthFailure(message: 'Not authenticated', code: 'not-authenticated'),
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message ?? 'Failed to change password',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to change password: $e',
          code: 'password-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .delete();

      await firestore.collection('profiles').doc(userId).delete();

      final user = firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message ?? 'Failed to delete account',
          code: e.code,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to delete account: $e',
          code: 'delete-error',
        ),
      );
    }
  }
}
