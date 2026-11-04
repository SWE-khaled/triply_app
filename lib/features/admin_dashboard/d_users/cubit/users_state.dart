part of 'users_cubit.dart';

/// The state of the Users tab.
@immutable
sealed class UsersState {
  const UsersState();
}

/// Nothing has been requested yet.
final class UsersInitial extends UsersState {
  const UsersInitial();
}

/// The tourist list is being loaded for the first time.
final class UsersLoading extends UsersState {
  const UsersLoading();
}

/// The tourist stream failed.
final class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);
}

/// The live tourist list, with the current search applied.
final class UsersSuccess extends UsersState {
  final List<AdminTourist> tourists;
  final String query;
  final bool busy;

  const UsersSuccess({
    required this.tourists,
    this.query = '',
    this.busy = false,
  });

  List<AdminTourist> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return tourists;
    return tourists.where((tourist) {
      return tourist.name.toLowerCase().contains(q) ||
          tourist.email.toLowerCase().contains(q) ||
          tourist.phone.toLowerCase().contains(q);
    }).toList();
  }

  UsersSuccess copyWith({
    List<AdminTourist>? tourists,
    String? query,
    bool? busy,
  }) {
    return UsersSuccess(
      tourists: tourists ?? this.tourists,
      query: query ?? this.query,
      busy: busy ?? this.busy,
    );
  }
}
