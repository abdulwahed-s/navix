part of 'prd_editor_bloc.dart';

abstract class PrdEditorState extends Equatable {
  const PrdEditorState();

  @override
  List<Object?> get props => [];
}

class PrdEditorInitial extends PrdEditorState {
  const PrdEditorInitial();
}

class PrdEditorReady extends PrdEditorState {
  final List<PrdEditorMessage> messages;
  final PrdEditorContext context;
  final bool isLoading;
  final String? error;

  const PrdEditorReady({
    required this.messages,
    required this.context,
    this.isLoading = false,
    this.error,
  });

  PrdEntity get currentPrd => context.prd;

  PrdEditorReady copyWith({
    List<PrdEditorMessage>? messages,
    PrdEditorContext? context,
    bool? isLoading,
    String? error,
  }) {
    return PrdEditorReady(
      messages: messages ?? this.messages,
      context: context ?? this.context,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [messages, context, isLoading, error];
}
