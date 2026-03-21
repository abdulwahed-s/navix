import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> createProfile(ProfileModel profile);

  Future<ProfileModel> updateProfile(ProfileModel profile);

  Future<ProfileModel?> getProfile(String userId);

  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  });

  Future<void> deleteProfilePicture(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({required this.firestore, required this.storage});

  CollectionReference get _usersCollection => firestore.collection('users');

  DocumentReference _profileDoc(String userId) =>
      _usersCollection.doc(userId).collection('profile').doc('main');

  @override
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      final now = DateTime.now();
      final profileWithTimestamp = profile.copyWith(
        createdAt: now,
        updatedAt: now,
      );

      await _profileDoc(profile.userId).set(profileWithTimestamp.toJson());

      return profileWithTimestamp;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to create profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred while creating profile',
        code: e.toString(),
      );
    }
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final profileWithTimestamp = profile.copyWith(updatedAt: DateTime.now());

      await _profileDoc(profile.userId).update(profileWithTimestamp.toJson());

      return profileWithTimestamp;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to update profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred while updating profile',
        code: e.toString(),
      );
    }
  }

  @override
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final doc = await _profileDoc(userId).get();

      if (!doc.exists) {
        return null;
      }

      return ProfileModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to get profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred while getting profile',
        code: e.toString(),
      );
    }
  }

  @override
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ref = storage.ref().child('profiles/$userId/profile_pic.jpg');

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: 'Failed to upload profile picture: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred while uploading image',
        code: e.toString(),
      );
    }
  }

  @override
  Future<void> deleteProfilePicture(String userId) async {
    try {
      final ref = storage.ref().child('profiles/$userId/profile_pic.jpg');
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw ServerException(
          message: 'Failed to delete profile picture: ${e.message}',
          code: e.code,
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred while deleting image',
        code: e.toString(),
      );
    }
  }
}
