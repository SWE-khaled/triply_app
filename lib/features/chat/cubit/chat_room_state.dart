import 'package:triply/core/data/models/chat.dart';
import 'package:triply/core/data/models/chat_message.dart';

const Object _unsetChatRoomError = Object();

/// The chat room: messages, typing, read receipts and write state.
class ChatRoomState {
  final Chat? chat;
  final List<ChatMessage> messages;

  /// Uids whose typing marker was active on the last snapshot.
  final Set<String> typingUids;

  final bool isLoading;
  final bool isLoadingMore;

  /// True while another page of older messages may exist.
  final bool hasMore;

  /// Set when a write was denied (inactive account, lost access).
  final bool isReadOnly;

  final bool isSending;
  final bool isEditing;
  final bool isDeleting;
  final bool isReporting;

  /// A load/subscription failure.
  final String? error;

  /// The last send/edit/delete/report failure.
  final String? actionError;

  const ChatRoomState({
    this.chat,
    this.messages = const <ChatMessage>[],
    this.typingUids = const <String>{},
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.isReadOnly = false,
    this.isSending = false,
    this.isEditing = false,
    this.isDeleting = false,
    this.isReporting = false,
    this.error,
    this.actionError,
  });

  bool get isBusy => isSending || isEditing || isDeleting || isReporting;

  ChatRoomState copyWith({
    Chat? chat,
    List<ChatMessage>? messages,
    Set<String>? typingUids,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isReadOnly,
    bool? isSending,
    bool? isEditing,
    bool? isDeleting,
    bool? isReporting,
    Object? error = _unsetChatRoomError,
    Object? actionError = _unsetChatRoomError,
  }) {
    return ChatRoomState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      typingUids: typingUids ?? this.typingUids,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isSending: isSending ?? this.isSending,
      isEditing: isEditing ?? this.isEditing,
      isDeleting: isDeleting ?? this.isDeleting,
      isReporting: isReporting ?? this.isReporting,
      error: identical(error, _unsetChatRoomError)
          ? this.error
          : error as String?,
      actionError: identical(actionError, _unsetChatRoomError)
          ? this.actionError
          : actionError as String?,
    );
  }
}
