import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_with_ai_usecase.dart';

part 'ai_chat_event.dart';
part 'ai_chat_state.dart';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final ChatWithAIUseCase chatWithAIUseCase;

  AIChatBloc({required this.chatWithAIUseCase}) : super(const AIChatInitial()) {
    on<SendChatMessage>(_onSendChatMessage);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<AIChatState> emit,
  ) async {
    final currentMessages = state is AIChatLoaded
        ? (state as AIChatLoaded).messages
        : <ChatMessage>[];

    final userMessage = ChatMessage(
      role: ChatRole.user,
      content: event.message,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...currentMessages, userMessage];

    emit(
      AIChatLoaded(
        messages: updatedMessages,
        isLoading: true,
        context: event.context,
      ),
    );

    final result = await chatWithAIUseCase(
      ChatWithAIParams(
        message: event.message,
        chatHistory: currentMessages,
        context: event.context,
      ),
    );

    result.fold(
      (failure) {
        emit(
          AIChatError(
            message: failure.message,
            previousMessages: updatedMessages,
            context: event.context,
          ),
        );
      },
      (response) {
        final aiMessage = ChatMessage(
          role: ChatRole.assistant,
          content: response,
          timestamp: DateTime.now(),
        );

        emit(
          AIChatLoaded(
            messages: [...updatedMessages, aiMessage],
            isLoading: false,
            context: event.context,
          ),
        );
      },
    );
  }

  void _onClearChat(ClearChat event, Emitter<AIChatState> emit) {
    emit(const AIChatInitial());
  }
}
