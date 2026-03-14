import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCounts;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCounts = const {},
    required this.updatedAt,
  });

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.first,
    );
  }

  String getOtherParticipantName(String currentUserId) {
    final otherId = getOtherParticipantId(currentUserId);
    final name = participantNames[otherId];

    return (name != null && name.trim().isNotEmpty) ? name : 'User';
  }

  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  @override
  List<Object?> get props => [
    id,
    participantIds,
    participantNames,
    lastMessage,
    lastMessageTime,
    unreadCounts,
    updatedAt,
  ];
}
