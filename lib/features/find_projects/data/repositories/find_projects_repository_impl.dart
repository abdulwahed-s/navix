import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/open_role.dart';
import '../../domain/entities/project_join_request_entity.dart';
import '../../domain/entities/project_listing_entity.dart';
import '../../domain/repositories/find_projects_repository.dart';

class FindProjectsRepositoryImpl implements FindProjectsRepository {
  final FirebaseFirestore firestore;

  FindProjectsRepositoryImpl({required this.firestore});

  @override
  Future<Either<Failure, List<ProjectListingEntity>>>
  getProjectListings() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final snapshot = await firestore
          .collection('project_listings')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      Set<String> userProjectIds = {};
      Set<String> appliedListingIds = {};
      Set<String> invitedProjectIds = {};

      if (currentUserId != null) {
        final userProjectsSnapshot = await firestore
            .collection('projects')
            .where('memberIds', arrayContains: currentUserId)
            .get();
        userProjectIds = userProjectsSnapshot.docs.map((d) => d.id).toSet();

        final userRequestsSnapshot = await firestore
            .collection('project_join_requests')
            .where('applicantId', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending')
            .get();
        appliedListingIds = userRequestsSnapshot.docs
            .map((d) => d.data()['listingId'] as String)
            .toSet();

        final userInvitationsSnapshot = await firestore
            .collection('invitations')
            .where('inviteeId', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending')
            .get();
        invitedProjectIds = userInvitationsSnapshot.docs
            .map((d) => d.data()['projectId'] as String)
            .toSet();
      }

      final listings = snapshot.docs
          .map((doc) {
            final listing = _listingFromDoc(doc);
            if (appliedListingIds.contains(listing.id)) {
              return ProjectListingEntity(
                id: listing.id,
                projectId: listing.projectId,
                leaderId: listing.leaderId,
                projectName: listing.projectName,
                projectDescription: listing.projectDescription,
                leaderMessage: listing.leaderMessage,
                hasApplied: true,
                openRoles: listing.openRoles,
                status: listing.status,
                createdAt: listing.createdAt,
                updatedAt: listing.updatedAt,
              );
            }
            return listing;
          })
          .where(
            (listing) =>
                listing.leaderId != currentUserId &&
                !userProjectIds.contains(listing.projectId) &&
                !invitedProjectIds.contains(listing.projectId),
          )
          .toList();

      return Right(listings);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to load project listings: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> publishProjectListing({
    required String projectId,
    required String projectName,
    required String projectDescription,
    required String leaderId,
    String? leaderMessage,
    required List<OpenRole> openRoles,
  }) async {
    try {
      final existing = await firestore
          .collection('project_listings')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'active')
          .get();

      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          'projectName': projectName,
          'projectDescription': projectDescription,
          'leaderMessage': leaderMessage,
          'openRoles': openRoles.map((r) => r.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await firestore.collection('project_listings').add({
          'projectId': projectId,
          'leaderId': leaderId,
          'projectName': projectName,
          'projectDescription': projectDescription,
          'leaderMessage': leaderMessage,
          'openRoles': openRoles.map((r) => r.toMap()).toList(),
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to publish project listing: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeProjectListing({
    required String listingId,
  }) async {
    try {
      await firestore.collection('project_listings').doc(listingId).update({
        'status': 'closed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to remove project listing: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ProjectListingEntity?>> getListingForProject({
    required String projectId,
  }) async {
    try {
      final snapshot = await firestore
          .collection('project_listings')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return const Right(null);
      }

      return Right(_listingFromDoc(snapshot.docs.first));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get project listing: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> applyToProject({
    required String listingId,
    required String projectId,
    required String leaderId,
    required String roleName,
    String? message,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return const Left(AuthFailure(message: 'Not authenticated'));
      }

      final existing = await firestore
          .collection('project_join_requests')
          .where('projectId', isEqualTo: projectId)
          .where('applicantId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        return const Left(
          ValidationFailure(
            message: 'You already have a pending application for this project',
          ),
        );
      }

      await firestore.collection('project_join_requests').add({
        'projectId': projectId,
        'listingId': listingId,
        'applicantId': currentUserId,
        'leaderId': leaderId,
        'roleName': roleName,
        'message': message,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
      });

      String applicantName = 'Someone';
      try {
        final profileDoc = await firestore
            .collection('users')
            .doc(currentUserId)
            .collection('profile')
            .doc('main')
            .get();
        if (profileDoc.exists) {
          applicantName = profileDoc.data()?['name'] as String? ?? 'Someone';
        }
      } catch (_) {}

      await firestore.collection('notifications').add({
        'userId': leaderId,
        'title': 'Join Request',
        'body': '$applicantName wants to join your project as $roleName',
        'type': 'projectJoinRequest',
        'relatedId': projectId,
        'read': false,
        'actionStatus': 'pending',
        'data': {
          'applicantId': currentUserId,
          'applicantName': applicantName,
          'roleName': roleName,
          'message': message,
          'projectId': projectId,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('users').doc(leaderId).set({
        'unreadNotificationCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to apply to project: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ProjectJoinRequestEntity>>>
  getJoinRequestsForProject({required String projectId}) async {
    try {
      final snapshot = await firestore
          .collection('project_join_requests')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final requests = snapshot.docs
          .map((doc) => _joinRequestFromDoc(doc))
          .toList();

      return Right(requests);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load join requests: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> respondToJoinRequest({
    required String requestId,
    required bool accepted,
    required String projectId,
    required String applicantId,
    required String projectName,
  }) async {
    try {
      final batch = firestore.batch();
      final requestRef = firestore
          .collection('project_join_requests')
          .doc(requestId);

      batch.update(requestRef, {
        'status': accepted ? 'accepted' : 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      if (accepted) {
        final projectRef = firestore.collection('projects').doc(projectId);
        batch.update(projectRef, {
          'memberIds': FieldValue.arrayUnion([applicantId]),
        });
      }

      await batch.commit();

      await firestore.collection('notifications').add({
        'userId': applicantId,
        'title': accepted ? 'Application Accepted' : 'Application Declined',
        'body': accepted
            ? 'Your request to join $projectName has been accepted!'
            : 'Your request to join $projectName was declined.',
        'type': 'projectJoinResponse',
        'relatedId': projectId,
        'read': false,
        'actionStatus': accepted ? 'accepted' : 'rejected',
        'data': {
          'projectId': projectId,
          'projectName': projectName,
          'accepted': accepted,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('users').doc(applicantId).set({
        'unreadNotificationCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to respond to join request: $e'),
      );
    }
  }

  ProjectListingEntity _listingFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectListingEntity(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      leaderId: data['leaderId'] as String? ?? '',
      projectName: data['projectName'] as String? ?? '',
      projectDescription: data['projectDescription'] as String? ?? '',
      leaderMessage: data['leaderMessage'] as String?,
      openRoles:
          (data['openRoles'] as List<dynamic>?)
              ?.map((r) => OpenRole.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
      status: data['status'] as String? ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ProjectJoinRequestEntity _joinRequestFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectJoinRequestEntity(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      listingId: data['listingId'] as String? ?? '',
      applicantId: data['applicantId'] as String? ?? '',
      leaderId: data['leaderId'] as String? ?? '',
      roleName: data['roleName'] as String? ?? '',
      message: data['message'] as String?,
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }
}
