class ProfileState {
  final bool notificationsEnabled;
  final String selectedLanguage;

  const ProfileState({
    this.notificationsEnabled = true,
    this.selectedLanguage = 'English',
  });

  ProfileState copyWith({
    bool? notificationsEnabled,
    String? selectedLanguage,
  }) {
    return ProfileState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}
