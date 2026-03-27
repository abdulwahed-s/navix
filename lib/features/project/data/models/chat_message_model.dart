import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.projectId,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.timestamp,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot doc,
    String projectId,
  ) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessageModel(
      id: doc.id,
      projectId: projectId,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      projectId: entity.projectId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      content: entity.content,
      timestamp: entity.timestamp,
    );
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      id: id,
      projectId: projectId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
