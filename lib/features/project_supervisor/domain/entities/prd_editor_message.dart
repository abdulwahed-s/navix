import 'package:equatable/equatable.dart';

class PrdEditorMessage extends Equatable {
  final String id;
  final PrdEditorRole role;
  final String content;
  final DateTime timestamp;

  final Map<String, dynamic>? suggestedPrdUpdates;

  final bool updatePending;

  const PrdEditorMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestedPrdUpdates,
    this.updatePending = false,
  });

  factory PrdEditorMessage.user({required String content}) {
    return PrdEditorMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: PrdEditorRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory PrdEditorMessage.assistant({
    required String content,
    Map<String, dynamic>? suggestedUpdates,
  }) {
    return PrdEditorMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: PrdEditorRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      suggestedPrdUpdates: suggestedUpdates,
      updatePending: suggestedUpdates != null,
    );
  }

  bool get hasSuggestedUpdates => suggestedPrdUpdates != null;

  PrdEditorMessage copyWith({bool? updatePending}) {
    return PrdEditorMessage(
      id: id,
      role: role,
      content: content,
      timestamp: timestamp,
      suggestedPrdUpdates: suggestedPrdUpdates,
      updatePending: updatePending ?? this.updatePending,
    );
  }

  @override
  List<Object?> get props => [
    id,
    role,
    content,
    timestamp,
    suggestedPrdUpdates,
    updatePending,
  ];
}

enum PrdEditorRole { user, assistant }
