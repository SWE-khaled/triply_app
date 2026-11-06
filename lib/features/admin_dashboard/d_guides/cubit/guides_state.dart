part of 'guides_cubit.dart';

/// The state of the Guides tab.
@immutable
sealed class GuidesState {
  const GuidesState();
}

/// Nothing has been requested yet.
final class GuidesInitial extends GuidesState {
  const GuidesInitial();
}

/// The guide list is being loaded for the first time.
final class GuidesLoading extends GuidesState {
  const GuidesLoading();
}

/// The guide stream failed.
final class GuidesError extends GuidesState {
  final String message;

  const GuidesError(this.message);
}

/// The live guide list.
final class GuidesSuccess extends GuidesState {
  final List<AdminGuide> guides;
  final bool busy;

  const GuidesSuccess({required this.guides, this.busy = false});

  int get pendingCount =>
      guides.where((guide) => guide.status == 'pending').length;

  GuidesSuccess copyWith({List<AdminGuide>? guides, bool? busy}) {
    return GuidesSuccess(
      guides: guides ?? this.guides,
      busy: busy ?? this.busy,
    );
  }
}
