import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final ChatRole role;

  final String content;

  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [role, content, timestamp];
}

enum ChatRole {
  user,
  assistant;

  String get displayName {
    switch (this) {
      case ChatRole.user:
        return 'You';
      case ChatRole.assistant:
        return 'Navix AI';
    }
  }
}

class ChatContext extends Equatable {
  final String projectId;

  final String projectName;

  final String projectDescription;

  final List<String> skills;

  final String? taskId;

  final String? taskName;

  final String? taskDescription;

  final String? taskDetailedDescription;

  const ChatContext({
    required this.projectId,
    required this.projectName,
    required this.projectDescription,
    required this.skills,
    this.taskId,
    this.taskName,
    this.taskDescription,
    this.taskDetailedDescription,
  });

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    projectDescription,
    skills,
    taskId,
    taskName,
    taskDescription,
    taskDetailedDescription,
  ];
}
