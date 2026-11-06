import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/repositories/admin_guides_repository.dart';

part 'guides_state.dart';

/// Owns the Guides tab: the live verification list and the approve /
/// reject / suspend decisions.
class GuidesCubit extends Cubit<GuidesState> {
  GuidesCubit({AdminGuidesRepository? repository})
    : _repository = repository ?? AdminGuidesRepository(),
      super(const GuidesInitial());

  final AdminGuidesRepository _repository;

  StreamSubscription<List<AdminGuide>>? _subscription;
  List<AdminGuide> _guides = const [];
  bool _started = false;

  /// Subscribes to the guide stream. Calling it twice is a no-op.
  void start() {
    if (_started) return;
    _started = true;
    emit(const GuidesLoading());
    _subscription = _repository.watchGuides().listen(
      (guides) {
        _guides = guides;
        _emitSuccess();
      },
      onError: (_) {
        if (!isClosed) emit(const GuidesError('Could not load guides.'));
      },
    );
  }

  /// Approves the guide's documents and writes the decision back.
  Future<bool> approve(AdminGuide guide) async {
    if (guide.uid.isEmpty) return false;
    final current = state;
    if (current is! GuidesSuccess) return false;

    final optimistic = current.copyWith(
      guides: _withStatus(current.guides, guide.uid, 'approved'),
      busy: true,
    );
    emit(optimistic);

    final ok = await _repository.decideVerification(
      guideId: guide.uid,
      approve: true,
    );
    return _finish(current, optimistic, ok);
  }

  /// Rejects the guide's documents and writes the decision back.
  Future<bool> reject(AdminGuide guide, String reason) async {
    if (guide.uid.isEmpty) return false;
    final current = state;
    if (current is! GuidesSuccess) return false;

    final optimistic = current.copyWith(
      guides: _withStatus(current.guides, guide.uid, 'suspended'),
      busy: true,
    );
    emit(optimistic);

    final ok = await _repository.decideVerification(
      guideId: guide.uid,
      approve: false,
      rejectionReason: reason,
    );
    return _finish(current, optimistic, ok);
  }

  /// Suspends the guide — they can no longer publish or be booked.
  Future<bool> suspend(AdminGuide guide) async {
    if (guide.uid.isEmpty) return false;
    final current = state;
    if (current is! GuidesSuccess) return false;

    final optimistic = current.copyWith(
      guides: _withStatus(current.guides, guide.uid, 'suspended'),
      busy: true,
    );
    emit(optimistic);

    final ok = await _repository.suspendGuide(guide.uid);
    return _finish(current, optimistic, ok);
  }

  bool _finish(GuidesSuccess previous, GuidesSuccess optimistic, bool ok) {
    if (isClosed) return ok;
    if (ok) {
      emit(optimistic.copyWith(busy: false));
    } else {
      emit(previous.copyWith(busy: false));
    }
    return ok;
  }

  List<AdminGuide> _withStatus(
    List<AdminGuide> guides,
    String uid,
    String status,
  ) {
    return [
      for (final guide in guides)
        if (guide.uid == uid) guide.copyWith(status: status) else guide,
    ];
  }

  void _emitSuccess() {
    if (isClosed) return;
    emit(GuidesSuccess(guides: List.unmodifiable(_guides)));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
