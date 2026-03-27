import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String projectId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    projectId,
    senderId,
    senderName,
    content,
    timestamp,
  ];
}
