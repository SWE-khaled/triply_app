/// Which app the chat screen is shown in.
///
/// Both roles use the same screens; the audience only decides the labels,
/// the fallback name of the other participant and whether the guide bottom
/// navigation is shown.
enum ChatAudience {
  tourist,
  guide;

  bool get isTourist => this == ChatAudience.tourist;

  /// The label under the other participant's name.
  String get otherRoleLabel => isTourist ? 'Tour Guide' : 'Traveler';

  /// The fallback name when the copied profile is empty.
  String get otherFallbackName => isTourist ? 'Tour Guide' : 'Traveler';

  String get listTitle => isTourist ? 'Messages' : 'Chats';

  String get listSubtitle => isTourist
      ? 'Your conversations with tour guides'
      : 'Stay connected with your travelers.';
}
