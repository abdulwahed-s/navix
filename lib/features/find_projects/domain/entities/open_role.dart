import 'package:equatable/equatable.dart';

class OpenRole extends Equatable {
  final String roleName;

  final String? description;

  const OpenRole({required this.roleName, this.description});

  factory OpenRole.fromMap(Map<String, dynamic> map) {
    return OpenRole(
      roleName: map['roleName'] as String? ?? '',
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roleName': roleName,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [roleName, description];
}
