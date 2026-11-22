part of 'support_center_cubit.dart';

@immutable
sealed class SupportCenterState {
  const SupportCenterState();
}

final class SupportCenterInitial extends SupportCenterState {
  const SupportCenterInitial();
}

final class SupportCenterLoading extends SupportCenterState {
  const SupportCenterLoading();
}

final class SupportCenterError extends SupportCenterState {
  final String message;

  const SupportCenterError(this.message);
}

final class SupportCenterSuccess extends SupportCenterState {
  final List<ContactMessageModel> messages;
  final String query;
  final String statusFilter;
  final String roleFilter;
  final Set<String> busyIds;

  const SupportCenterSuccess({
    required this.messages,
    required this.query,
    required this.statusFilter,
    required this.roleFilter,
    required this.busyIds,
  });

  List<ContactMessageModel> get filtered {
    final q = query.trim().toLowerCase();
    return messages.where((message) {
      final matchesStatus =
          statusFilter == 'all' || message.status == statusFilter;
      final matchesRole = roleFilter == 'all' || message.userRole == roleFilter;
      if (!matchesStatus || !matchesRole) return false;
      if (q.isEmpty) return true;
      return [
        message.userName,
        message.userEmail,
        message.userRole,
        message.message,
        message.type,
        message.status,
        message.userId,
      ].any((value) => value.toLowerCase().contains(q));
    }).toList();
  }
}
