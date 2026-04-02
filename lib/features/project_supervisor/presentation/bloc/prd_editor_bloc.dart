import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ai/domain/entities/prd_entity.dart';
import '../../domain/entities/prd_editor_context.dart';
import '../../domain/entities/prd_editor_message.dart';
import '../../domain/usecases/edit_prd_with_ai_usecase.dart';

part 'prd_editor_event.dart';
part 'prd_editor_state.dart';

class PrdEditorBloc extends Bloc<PrdEditorEvent, PrdEditorState> {
  final EditPrdWithAIUseCase editPrdWithAIUseCase;

  PrdEditorBloc({required this.editPrdWithAIUseCase})
    : super(const PrdEditorInitial()) {
    on<InitializePrdEditor>(_onInitialize);
    on<SendPrdEditorMessage>(_onSendMessage);
    on<AcceptPrdUpdate>(_onAcceptUpdate);
    on<RejectPrdUpdate>(_onRejectUpdate);
    on<ClearPrdEditorChat>(_onClearChat);
  }

  void _onInitialize(InitializePrdEditor event, Emitter<PrdEditorState> emit) {
    emit(PrdEditorReady(messages: const [], context: event.context));
  }

  Future<void> _onSendMessage(
    SendPrdEditorMessage event,
    Emitter<PrdEditorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PrdEditorReady) return;

    final userMessage = PrdEditorMessage.user(content: event.message);
    final updatedMessages = [...currentState.messages, userMessage];

    emit(
      currentState.copyWith(
        messages: updatedMessages,
        isLoading: true,
        error: null,
      ),
    );

    final result = await editPrdWithAIUseCase(
      EditPrdWithAIParams(
        message: event.message,
        history: currentState.messages,
        context: currentState.context,
      ),
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            messages: updatedMessages,
            isLoading: false,
            error: failure.message,
          ),
        );
      },
      (response) {
        emit(
          PrdEditorReady(
            messages: [...updatedMessages, response],
            context: currentState.context,
            isLoading: false,
          ),
        );
      },
    );
  }

  void _onAcceptUpdate(AcceptPrdUpdate event, Emitter<PrdEditorState> emit) {
    final currentState = state;
    if (currentState is! PrdEditorReady) return;

    final updatedPrd = _applyUpdates(currentState.context.prd, event.updates);

    final updatedMessages = currentState.messages.map((msg) {
      if (msg.id == event.messageId && msg.hasSuggestedUpdates) {
        return msg.copyWith(updatePending: false);
      }
      return msg;
    }).toList();

    final updatedContext = currentState.context.copyWith(prd: updatedPrd);

    emit(PrdEditorReady(messages: updatedMessages, context: updatedContext));
  }

  void _onRejectUpdate(RejectPrdUpdate event, Emitter<PrdEditorState> emit) {
    final currentState = state;
    if (currentState is! PrdEditorReady) return;

    final updatedMessages = currentState.messages.map((msg) {
      if (msg.id == event.messageId && msg.hasSuggestedUpdates) {
        return msg.copyWith(updatePending: false);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  void _onClearChat(ClearPrdEditorChat event, Emitter<PrdEditorState> emit) {
    final currentState = state;
    if (currentState is PrdEditorReady) {
      emit(PrdEditorReady(messages: const [], context: currentState.context));
    }
  }

  PrdEntity _applyUpdates(PrdEntity prd, Map<String, dynamic> updates) {
    return prd.copyWith(
      title: updates['title'] as String?,
      description: updates['description'] as String?,
      problemStatement: updates['problemStatement'] as String?,
      projectObjective: updates['projectObjective'] as String?,
      targetUsers: updates['targetUsers'] as String?,
      inScope: (updates['inScope'] as List?)?.cast<String>(),
      outOfScope: (updates['outOfScope'] as List?)?.cast<String>(),
      coreFeatures: (updates['coreFeatures'] as List?)?.cast<String>(),
      functionalRequirements: (updates['functionalRequirements'] as List?)
          ?.cast<String>(),
      nonFunctionalRequirements: (updates['nonFunctionalRequirements'] as List?)
          ?.cast<String>(),
      acceptanceCriteria: (updates['acceptanceCriteria'] as List?)
          ?.cast<String>(),
    );
  }
}
