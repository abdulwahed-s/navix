import 'package:equatable/equatable.dart';

class UserSettingsEntity extends Equatable {
  final Map<String, bool> notificationPreferences;
  final Map<String, String> privacySettings;
  final String themeMode;
  final String language;

  const UserSettingsEntity({
    this.notificationPreferences = const {},
    this.privacySettings = const {},
    this.themeMode = 'system',
    this.language = 'en',
  });

  factory UserSettingsEntity.defaults() {
    return const UserSettingsEntity(
      notificationPreferences: {
        'taskAssignments': true,
        'projectUpdates': true,
        'messages': true,
        'riskAlerts': true,
      },
      privacySettings: {
        'profileVisibility': 'public',
        'whoCanFindYou': 'everyone',
      },
      themeMode: 'system',
      language: 'en',
    );
  }

  UserSettingsEntity copyWith({
    Map<String, bool>? notificationPreferences,
    Map<String, String>? privacySettings,
    String? themeMode,
    String? language,
  }) {
    return UserSettingsEntity(
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      privacySettings: privacySettings ?? this.privacySettings,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [
    notificationPreferences,
    privacySettings,
    themeMode,
    language,
  ];
}
