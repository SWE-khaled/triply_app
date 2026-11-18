import 'package:flutter/foundation.dart';

/// The chat room currently visible to the user, across both roles.
///
/// It is intentionally session-only: no Firestore read or write is needed to
/// know that a message belongs to the room the user is already looking at.
/// Consumers listen for changes so unread counters can be recalculated as
/// soon as a room opens or closes.
class ActiveChatTracker {
  ActiveChatTracker._();

  static final ActiveChatTracker instance = ActiveChatTracker._();

  final ValueNotifier<String?> _current = ValueNotifier<String?>(null);

  String? get currentId => _current.value;

  bool isActive(String chatId) => chatId.isNotEmpty && _current.value == chatId;

  void addListener(VoidCallback listener) => _current.addListener(listener);

  void removeListener(VoidCallback listener) =>
      _current.removeListener(listener);

  /// Marks [chatId] as the visible room.
  void open(String chatId) {
    if (chatId.isEmpty || _current.value == chatId) return;
    _current.value = chatId;
  }

  /// Clears the marker, optionally only when [chatId] is still the active
  /// one. That prevents an older screen's dispose from closing a newer room.
  void close([String? chatId]) {
    if (chatId != null && chatId != _current.value) return;
    if (_current.value == null) return;
    _current.value = null;
  }

  /// App backgrounded: no chat is visible, even if the route stays mounted.
  void pause() => close();
}
