part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ChatEvent {
  final String userId;

  const LoadConversations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SubscribeToConversations extends ChatEvent {
  final String userId;

  const SubscribeToConversations({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ConversationsUpdated extends ChatEvent {
  final List<ConversationEntity> conversations;

  const ConversationsUpdated(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class DeleteConversation extends ChatEvent {
  final String conversationId;

  const DeleteConversation({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class LoadConnectedUsers extends ChatEvent {
  final String userId;

  const LoadConnectedUsers({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class StartConversationWithUser extends ChatEvent {
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;

  const StartConversationWithUser({
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  List<Object?> get props => [
    currentUserId,
    currentUserName,
    otherUserId,
    otherUserName,
  ];
}
