part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ConversationEntity> conversations;

  const ChatLoaded(this.conversations);

  int getTotalUnread(String userId) {
    return conversations.fold(0, (sum, c) => sum + c.getUnreadCount(userId));
  }

  @override
  List<Object?> get props => [conversations];
}

class ConversationDeleted extends ChatState {
  final ChatLoaded previousState;

  const ConversationDeleted(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class ConnectedUsersLoading extends ChatState {
  final List<ConversationEntity>? conversations;

  const ConnectedUsersLoading({this.conversations});

  @override
  List<Object?> get props => [conversations];
}

class ConnectedUsersLoaded extends ChatState {
  final List<ProfileEntity> connectedUsers;
  final List<ConversationEntity>? conversations;

  const ConnectedUsersLoaded(this.connectedUsers, {this.conversations});

  @override
  List<Object?> get props => [connectedUsers, conversations];
}

class ConversationStarted extends ChatState {
  final ConversationEntity conversation;
  final List<ConversationEntity>? previousConversations;

  const ConversationStarted(this.conversation, {this.previousConversations});

  @override
  List<Object?> get props => [conversation, previousConversations];
}
