import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ChatRepository repository;
  final String senderId;
  final String senderName;

  StreamSubscription<List<MessageEntity>>? _subscription;
  String? _conversationId;

  ConversationBloc({
    required this.repository,
    required this.senderId,
    required this.senderName,
  }) : super(const ConversationInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SubscribeToMessages>(_onSubscribe);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoading());
    _conversationId = event.conversationId;

    final result = await repository.getMessages(event.conversationId);

    result.fold(
      (failure) => emit(ConversationError(failure.message)),
      (messages) => emit(
        ConversationLoaded(
          messages: messages,
          conversationId: event.conversationId,
        ),
      ),
    );
  }

  void _onSubscribe(
    SubscribeToMessages event,
    Emitter<ConversationState> emit,
  ) {
    _conversationId = event.conversationId;
    _subscription?.cancel();
    _subscription = repository.watchMessages(event.conversationId).listen((
      messages,
    ) {
      add(MessagesUpdated(messages));
    });

    repository.markAsRead(
      conversationId: event.conversationId,
      userId: event.currentUserId,
    );
  }

  void _onMessagesUpdated(
    MessagesUpdated event,
    Emitter<ConversationState> emit,
  ) {
    emit(
      ConversationLoaded(
        messages: event.messages,
        conversationId: _conversationId ?? '',
      ),
    );
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;

    ConversationLoaded? loadedState;
    if (currentState is ConversationLoaded) {
      loadedState = currentState;
    } else if (currentState is MessageSent) {
      loadedState = currentState.previousState;
    }

    if (loadedState == null) return;
    if (_conversationId == null) return;

    final result = await repository.sendMessage(
      conversationId: _conversationId!,
      senderId: senderId,
      senderName: senderName,
      text: event.text,
    );

    result.fold((failure) => emit(ConversationError(failure.message)), (_) {});
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
