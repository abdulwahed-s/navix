part of 'prd_editor_bloc.dart';

abstract class PrdEditorEvent extends Equatable {
  const PrdEditorEvent();

  @override
  List<Object?> get props => [];
}

class InitializePrdEditor extends PrdEditorEvent {
  final PrdEditorContext context;

  const InitializePrdEditor({required this.context});

  @override
  List<Object?> get props => [context];
}

class SendPrdEditorMessage extends PrdEditorEvent {
  final String message;

  const SendPrdEditorMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class AcceptPrdUpdate extends PrdEditorEvent {
  final String messageId;
  final Map<String, dynamic> updates;

  const AcceptPrdUpdate({required this.messageId, required this.updates});

  @override
  List<Object?> get props => [messageId, updates];
}

class RejectPrdUpdate extends PrdEditorEvent {
  final String messageId;

  const RejectPrdUpdate({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class ClearPrdEditorChat extends PrdEditorEvent {
  const ClearPrdEditorChat();
}
