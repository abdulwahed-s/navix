import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/profile_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  StreamSubscription<List<ConversationEntity>>? _subscription;

  ChatBloc({required this.repository}) : super(const ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<SubscribeToConversations>(_onSubscribe);
    on<ConversationsUpdated>(_onConversationsUpdated);
    on<DeleteConversation>(_onDeleteConversation);
    on<LoadConnectedUsers>(_onLoadConnectedUsers);
    on<StartConversationWithUser>(_onStartConversation);
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await repository.getConversations(event.userId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversations) => emit(ChatLoaded(conversations)),
    );
  }

  void _onSubscribe(SubscribeToConversations event, Emitter<ChatState> emit) {
    _subscription?.cancel();
    _subscription = repository.watchConversations(event.userId).listen((
      conversations,
    ) {
      add(ConversationsUpdated(conversations));
    });
  }

  void _onConversationsUpdated(
    ConversationsUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(ChatLoaded(event.conversations));
  }

  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatLoaded) return;

    final result = await repository.deleteConversation(event.conversationId);

    result.fold((failure) => emit(ChatError(failure.message)), (_) {
      final updatedConversations = currentState.conversations
          .where((c) => c.id != event.conversationId)
          .toList();
      emit(ConversationDeleted(ChatLoaded(updatedConversations)));
    });
  }

  Future<void> _onLoadConnectedUsers(
    LoadConnectedUsers event,
    Emitter<ChatState> emit,
  ) async {
    List<ConversationEntity>? currentConversations;
    if (state is ChatLoaded) {
      currentConversations = (state as ChatLoaded).conversations;
    } else if (state is ConnectedUsersLoaded) {
      currentConversations = (state as ConnectedUsersLoaded).conversations;
    } else if (state is ConversationStarted) {
      currentConversations =
          (state as ConversationStarted).previousConversations;
    } else if (state is ConnectedUsersLoading) {
      currentConversations = (state as ConnectedUsersLoading).conversations;
    }

    emit(ConnectedUsersLoading(conversations: currentConversations));

    final result = await repository.getConnectedUsers(event.userId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (users) => emit(
        ConnectedUsersLoaded(users, conversations: currentConversations),
      ),
    );
  }

  Future<void> _onStartConversation(
    StartConversationWithUser event,
    Emitter<ChatState> emit,
  ) async {
    List<ConversationEntity>? currentConversations;
    if (state is ChatLoaded) {
      currentConversations = (state as ChatLoaded).conversations;
    } else if (state is ConnectedUsersLoaded) {
      currentConversations = (state as ConnectedUsersLoaded).conversations;
    } else if (state is ConversationStarted) {
      currentConversations =
          (state as ConversationStarted).previousConversations;
    }

    final result = await repository.getOrCreateConversation(
      currentUserId: event.currentUserId,
      currentUserName: event.currentUserName,
      otherUserId: event.otherUserId,
      otherUserName: event.otherUserName,
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversation) => emit(
        ConversationStarted(
          conversation,
          previousConversations: currentConversations,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
