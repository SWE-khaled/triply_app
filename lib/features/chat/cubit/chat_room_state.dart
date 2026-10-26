import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';

/// The state of one conversation.
///
/// Every phase is a distinct class (no `copyWith`): the screen switches on
/// the state and reads only the fields that phase actually owns.
sealed class ChatRoomState {
  const ChatRoomState();
}

/// Nothing has been requested yet (also the first frame of a new chat).
final class ChatRoomInitial extends ChatRoomState {
  const ChatRoomInitial();
}

/// The chat, its messages and its typing markers are being subscribed.
final class ChatRoomLoading extends ChatRoomState {
  const ChatRoomLoading();
}

/// The live room.
final class ChatRoomSuccess extends ChatRoomState {
  final Chat? chat;
  final List<ChatMessage> messages;

  /// Uids whose typing marker was active on the last snapshot.
  final Set<String> typingUids;

  final bool isLoadingMore;

  /// True while another page of older messages may exist.
  final bool hasMore;

  /// Set when a write was denied (inactive account, lost access).
  final bool isReadOnly;

  final bool isSending;
  final bool isEditing;
  final bool isDeleting;
  final bool isReporting;

  /// The last send/edit/delete/report failure.
  final String? actionError;

  const ChatRoomSuccess({
    this.chat,
    this.messages = const <ChatMessage>[],
    this.typingUids = const <String>{},
    this.isLoadingMore = false,
    this.hasMore = false,
    this.isReadOnly = false,
    this.isSending = false,
    this.isEditing = false,
    this.isDeleting = false,
    this.isReporting = false,
    this.actionError,
  });

  bool get isBusy => isSending || isEditing || isDeleting || isReporting;

  /// True when this is a conversation that has no messages yet.
  bool get isEmpty => messages.isEmpty;
}

/// The room could not be loaded (missing chat, rules, network).
final class ChatRoomError extends ChatRoomState {
  final String error;

  /// A denied read is shown as a read-only room, not as a retryable bug.
  final bool isReadOnly;

  const ChatRoomError(this.error, {this.isReadOnly = false});
}
