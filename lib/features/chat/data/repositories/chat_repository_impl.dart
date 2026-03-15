import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../profile/data/models/skill_model.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({required this.firestore, required this.networkInfo});

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      final conversations = snapshot.docs.map((doc) {
        return _conversationFromDoc(doc);
      }).toList();

      return Right(conversations);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get conversations: $e',
          code: 'chat-error',
        ),
      );
    }
  }

  @override
  Stream<List<ConversationEntity>> watchConversations(String userId) {
    return firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _conversationFromDoc(doc)).toList(),
        );
  }

  @override
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
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
      final existing = await firestore
          .collection('conversations')
          .where('participantIds', arrayContains: currentUserId)
          .get();

      for (final doc in existing.docs) {
        final participants = List<String>.from(doc['participantIds'] ?? []);
        if (participants.contains(otherUserId)) {
          return Right(_conversationFromDoc(doc));
        }
      }

      String resolvedCurrentUserName = currentUserName;
      String resolvedOtherUserName = otherUserName;

      if (currentUserName.isEmpty || currentUserName == 'User') {
        resolvedCurrentUserName = await _fetchUserNameFromProfile(
          currentUserId,
        );
      }
      if (otherUserName.isEmpty || otherUserName == 'User') {
        resolvedOtherUserName = await _fetchUserNameFromProfile(otherUserId);
      }

      final now = DateTime.now();
      final docRef = await firestore.collection('conversations').add({
        'participantIds': [currentUserId, otherUserId],
        'participantNames': {
          currentUserId: resolvedCurrentUserName,
          otherUserId: resolvedOtherUserName,
        },
        'lastMessage': null,
        'lastMessageTime': null,
        'unreadCounts': {currentUserId: 0, otherUserId: 0},
        'updatedAt': Timestamp.fromDate(now),
      });

      return Right(
        ConversationEntity(
          id: docRef.id,
          participantIds: [currentUserId, otherUserId],
          participantNames: {
            currentUserId: resolvedCurrentUserName,
            otherUserId: resolvedOtherUserName,
          },
          updatedAt: now,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to create conversation: $e',
          code: 'conversation-error',
        ),
      );
    }
  }

  Future<String> _fetchUserNameFromProfile(String userId) async {
    try {
      final profileDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('main')
          .get();

      if (profileDoc.exists) {
        final name = profileDoc.data()?['name'] as String?;
        if (name != null && name.trim().isNotEmpty) {
          return name;
        }
      }
    } catch (_) {}
    return 'User';
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  ) async {
    try {
      final snapshot = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs.map((doc) {
        return _messageFromDoc(doc);
      }).toList();

      return Right(messages);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get messages: $e',
          code: 'messages-error',
        ),
      );
    }
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    return firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => _messageFromDoc(doc)).toList(),
        );
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
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
      final now = DateTime.now();

      final docRef = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
            'senderId': senderId,
            'senderName': senderName,
            'text': text,
            'timestamp': Timestamp.fromDate(now),
            'status': 'sent',
          });

      final convDoc = await firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      final participants = List<String>.from(
        convDoc.data()?['participantIds'] ?? [],
      );
      final unreadCounts = Map<String, dynamic>.from(
        convDoc.data()?['unreadCounts'] ?? {},
      );

      for (final participant in participants) {
        if (participant != senderId) {
          unreadCounts[participant] = (unreadCounts[participant] ?? 0) + 1;
        }
      }

      await firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCounts': unreadCounts,
        'updatedAt': Timestamp.fromDate(now),
      });

      return Right(
        MessageEntity(
          id: docRef.id,
          conversationId: conversationId,
          senderId: senderId,
          senderName: senderName,
          text: text,
          timestamp: now,
          status: MessageStatus.sent,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to send message: $e',
          code: 'send-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await firestore.collection('conversations').doc(conversationId).update({
        'unreadCounts.$userId': 0,
      });
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to mark as read: $e',
          code: 'read-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final messages = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      for (final doc in messages.docs) {
        await doc.reference.delete();
      }

      await firestore.collection('conversations').doc(conversationId).delete();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to delete conversation: $e',
          code: 'delete-error',
        ),
      );
    }
  }

  ConversationEntity _conversationFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ConversationEntity(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(
        (data['participantNames'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      ),
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCounts: Map<String, int>.from(
        (data['unreadCounts'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
        ),
      ),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  MessageEntity _messageFromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final typeString = data['type'] as String? ?? 'text';
    MessageType type;
    switch (typeString) {
      case 'sharedPost':
        type = MessageType.sharedPost;
        break;
      case 'sharedSurvey':
        type = MessageType.sharedSurvey;
        break;
      default:
        type = MessageType.text;
    }

    SharedPostData? sharedPost;
    if (data['sharedPost'] != null) {
      sharedPost = SharedPostData.fromMap(
        Map<String, dynamic>.from(data['sharedPost'] as Map),
      );
    }

    SharedSurveyData? sharedSurvey;
    if (data['sharedSurvey'] != null) {
      sharedSurvey = SharedSurveyData.fromMap(
        Map<String, dynamic>.from(data['sharedSurvey'] as Map),
      );
    }

    return MessageEntity(
      id: doc.id,
      conversationId: '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data['status'] as String?),
      type: type,
      sharedPost: sharedPost,
      sharedSurvey: sharedSurvey,
    );
  }

  MessageStatus _parseStatus(String? value) {
    switch (value) {
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendSharedPost({
    required String conversationId,
    required String senderId,
    required String senderName,
    required SharedPostData sharedPost,
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
      final now = DateTime.now();
      final previewText = '📢 ${sharedPost.title}';

      final docRef = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
            'senderId': senderId,
            'senderName': senderName,
            'text': previewText,
            'type': 'sharedPost',
            'sharedPost': sharedPost.toMap(),
            'timestamp': Timestamp.fromDate(now),
            'status': 'sent',
          });

      final convDoc = await firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      final participants = List<String>.from(
        convDoc.data()?['participantIds'] ?? [],
      );
      final unreadCounts = Map<String, dynamic>.from(
        convDoc.data()?['unreadCounts'] ?? {},
      );

      for (final participant in participants) {
        if (participant != senderId) {
          unreadCounts[participant] = (unreadCounts[participant] ?? 0) + 1;
        }
      }

      await firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': previewText,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCounts': unreadCounts,
        'updatedAt': Timestamp.fromDate(now),
      });

      return Right(
        MessageEntity(
          id: docRef.id,
          conversationId: conversationId,
          senderId: senderId,
          senderName: senderName,
          text: previewText,
          timestamp: now,
          status: MessageStatus.sent,
          type: MessageType.sharedPost,
          sharedPost: sharedPost,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to send shared post: $e',
          code: 'send-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getConnectedUsers(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'No internet connection',
          code: 'network-error',
        ),
      );
    }

    try {
      final connectionsSnapshot = await firestore
          .collection('connections')
          .where('userIds', arrayContains: userId)
          .get();

      if (connectionsSnapshot.docs.isEmpty) {
        return const Right([]);
      }

      final connectedUsers = <ProfileEntity>[];

      for (final doc in connectionsSnapshot.docs) {
        final userIds = List<String>.from(doc.data()['userIds'] ?? []);
        final otherUserId = userIds.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );

        if (otherUserId.isEmpty) continue;

        try {
          final profileDoc = await firestore
              .collection('users')
              .doc(otherUserId)
              .collection('profile')
              .doc('main')
              .get();

          if (profileDoc.exists) {
            final profileData = profileDoc.data() as Map<String, dynamic>;
            connectedUsers.add(
              ProfileEntity(
                userId: otherUserId,
                name: profileData['name'] as String? ?? 'Unknown',
                organization: profileData['organization'] as String?,
                profilePicUrl: profileData['profilePicUrl'] as String?,
                skills: SkillModel.parseSkillsList(profileData['skills']),
                portfolioLink: profileData['portfolioLink'] as String?,
                githubLink: profileData['githubLink'] as String?,
                otherLinks: List<String>.from(profileData['otherLinks'] ?? []),
              ),
            );
          }
        } catch (e) {
          continue;
        }
      }

      return Right(connectedUsers);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get connected users: $e',
          code: 'connections-error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendSharedSurvey({
    required String conversationId,
    required String senderId,
    required String senderName,
    required SharedSurveyData sharedSurvey,
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
      final now = DateTime.now();
      final previewText = '📋 ${sharedSurvey.title}';

      final docRef = await firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
            'senderId': senderId,
            'senderName': senderName,
            'text': previewText,
            'type': 'sharedSurvey',
            'sharedSurvey': sharedSurvey.toMap(),
            'timestamp': Timestamp.fromDate(now),
            'status': 'sent',
          });

      final convDoc = await firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      final participants = List<String>.from(
        convDoc.data()?['participantIds'] ?? [],
      );
      final unreadCounts = Map<String, dynamic>.from(
        convDoc.data()?['unreadCounts'] ?? {},
      );

      for (final participant in participants) {
        if (participant != senderId) {
          unreadCounts[participant] = (unreadCounts[participant] ?? 0) + 1;
        }
      }

      await firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': previewText,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCounts': unreadCounts,
        'updatedAt': Timestamp.fromDate(now),
      });

      return Right(
        MessageEntity(
          id: docRef.id,
          conversationId: conversationId,
          senderId: senderId,
          senderName: senderName,
          text: previewText,
          timestamp: now,
          status: MessageStatus.sent,
          type: MessageType.sharedSurvey,
          sharedSurvey: sharedSurvey,
        ),
      );
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to send shared survey: $e',
          code: 'send-error',
        ),
      );
    }
  }
}
