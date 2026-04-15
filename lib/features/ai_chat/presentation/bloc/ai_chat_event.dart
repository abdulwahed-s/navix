part of 'ai_chat_bloc.dart';

abstract class AIChatEvent extends Equatable {
  const AIChatEvent();

  @override
  List<Object?> get props => [];
}

class SendChatMessage extends AIChatEvent {
  final String message;
  final ChatContext context;

  const SendChatMessage({required this.message, required this.context});

  @override
  List<Object?> get props => [message, context];
}

class ClearChat extends AIChatEvent {
  const ClearChat();
}
