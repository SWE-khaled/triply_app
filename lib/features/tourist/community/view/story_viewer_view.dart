import 'dart:async';
import 'package:triply/core/theme/app_colors.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/story_actions_cubit.dart';
import '../cubit/story_actions_state.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../model/community_story.dart';
import '../widget/story_progress_bars.dart';
import '../widget/story_viewer_header.dart';

/// Full-screen viewer for ONE user's stories only.
class StoryViewerScreen extends StatefulWidget {
  /// The author's stories captured when the viewer was opened. The live list
  /// is owned by [StoryActionsCubit], which is provided above this widget.
  final List<CommunityStory> stories;
  final int initialIndex;

  /// Test seam. Production uses the system clock.
  final DateTime Function()? now;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.now,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _storyDuration = Duration(seconds: 5);
  static const _expiryCheckInterval = Duration(seconds: 1);

  late final PageController _pageController;
  late final AnimationController _progressController;
  late final StoryActionsCubit _actions;
  late int _currentIndex;
  Timer? _expiryTimer;
  bool _pruning = false;
  bool _closeRequested = false;

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _actions = context.read<StoryActionsCubit>();
    final stories = _actions.stories;
    _currentIndex = stories.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, stories.length - 1).toInt();
    _pageController = PageController(initialPage: _currentIndex);
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )..addStatusListener(_onProgressStatus);

    if (stories.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestClose());
    } else {
      _progressController.forward();
    }

    _expiryTimer = Timer.periodic(
      _expiryCheckInterval,
      (_) => _pruneExpired(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _expiryTimer?.cancel();
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pruneExpired();
    }
  }

  void _requestClose() {
    if (_closeRequested || !mounted) return;
    _closeRequested = true;
    _expiryTimer?.cancel();
    _progressController.stop();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNext();
    }
  }

  void _goToNext() {
    final stories = _actions.stories;
    if (stories.isEmpty) return;
    if (_currentIndex < stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _progressController
        ..reset()
        ..forward();
    }
  }

  void _onPageChanged(int index) {
    final stories = _actions.stories;
    if (index < 0 || index >= stories.length) return;
    if (!stories[index].isDisplayableAt(_now)) {
      _pruneExpired();
      return;
    }

    setState(() {
      _currentIndex = index;
    });

    _progressController
      ..reset()
      ..forward();
  }

  void _pause() {
    _progressController.stop();
  }

  void _resume() {
    _progressController.forward();
  }

  /// Asks the cubit to drop expired stories, then reconciles the page index
  /// with the new snapshot. The View never edits the story list itself.
  void _pruneExpired() {
    if (!mounted || _pruning || _closeRequested || _actions.stories.isEmpty) {
      return;
    }
    _pruning = true;
    try {
      final before = List<CommunityStory>.of(_actions.stories);
      _actions.pruneExpired(_now);
      final active = _actions.stories;
      if (active.length == before.length) return;
      _reconcileAfterListChange(before, active);
    } finally {
      _pruning = false;
    }
  }

  /// Keeps the viewed story in focus when pages disappear, advances to the
  /// next still-active story that followed it, or closes the viewer.
  void _reconcileAfterListChange(
    List<CommunityStory> before,
    List<CommunityStory> active,
  ) {
    if (!mounted || _closeRequested) return;
    if (active.isEmpty) {
      _requestClose();
      return;
    }

    final safeCurrent = before.isEmpty
        ? 0
        : _currentIndex.clamp(0, before.length - 1);
    final currentId = before[safeCurrent].id;
    final currentIndexInActive = active.indexWhere(
      (story) => story.id == currentId,
    );

    if (currentIndexInActive >= 0) {
      // The viewed story is still active; only older pages disappeared.
      setState(() => _currentIndex = currentIndexInActive);
      if (_pageController.hasClients &&
          _pageController.page?.round() != _currentIndex) {
        _pageController.jumpToPage(_currentIndex);
      }
      return;
    }

    // The viewed story expired. Find the next active story that followed it;
    // if there is none, close instead of falling back to an older story.
    CommunityStory? next;
    for (var i = _currentIndex + 1; i < before.length; i++) {
      final candidate = before[i];
      if (active.any((story) => story.id == candidate.id)) {
        next = candidate;
        break;
      }
    }

    if (next == null) {
      _requestClose();
      return;
    }

    setState(() => _currentIndex = active.indexWhere((s) => s.id == next!.id));
    if (_pageController.hasClients) {
      _pageController.jumpToPage(_currentIndex);
    }
    _progressController
      ..reset()
      ..forward();
  }

  Widget _imageError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Icon(
      Icons.broken_image_outlined,
      color: AppColors.textPrimary.withValues(alpha: 0.54),
      size: 48,
    );
  }

  Future<void> _confirmDelete(CommunityStory story) async {
    _pause();

    final confirmed = await ConfirmDeleteDialog.show(
      context,
      title: 'Deleting story',
      content: 'Are you sure you want to delete this story?',
    );

    if (!confirmed) {
      if (mounted) _resume();
      return;
    }
    if (!mounted) return;

    final before = List<CommunityStory>.of(_actions.stories);
    await _actions.delete(story);
    if (!mounted) return;

    final state = _actions.state;
    if (state is StoryDeleteError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      _resume();
      return;
    }

    _reconcileAfterListChange(before, _actions.stories);
  }

  @override
  Widget build(BuildContext context) {
    if (_closeRequested || _actions.stories.isEmpty) {
      return  Scaffold(backgroundColor: AppColors.backgroundPrimary);
    }

    return BlocBuilder<StoryActionsCubit, StoryActionsState>(
      builder: (context, state) {
        final stories = state.stories;
        if (stories.isEmpty) {
          return  Scaffold(backgroundColor: AppColors.backgroundPrimary);
        }
        final safeIndex = _currentIndex.clamp(0, stories.length - 1);
        final story = stories[safeIndex];

        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: stories.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final item = stories[index];

                    return GestureDetector(
                      onTapDown: (_) => _pause(),
                      onTapCancel: _resume,
                      onLongPress: _pause,
                      onLongPressUp: _resume,
                      onTapUp: (details) {
                        _resume();

                        final width = MediaQuery.of(context).size.width;

                        if (details.globalPosition.dx < width / 2) {
                          _goToPrevious();
                        } else {
                          _goToNext();
                        }
                      },
                      child: Center(
                        child: item.isLocalFile
                            ? Image.file(
                                File(item.imageUrl),
                                fit: BoxFit.contain,
                                errorBuilder: _imageError,
                              )
                            : Image.network(
                                item.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: _imageError,
                              ),
                      ),
                    );
                  },
                ),

                // Top progress bars
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: StoryProgressBars(
                    count: stories.length,
                    currentIndex: safeIndex,
                    progress: _progressController,
                  ),
                ),

                // Header
                Positioned(
                  top: 20,
                  left: 12,
                  right: 12,
                  child: StoryViewerHeader(
                    userName: story.userName,
                    avatarUrl: story.authorAvatarUrl,
                    isMine: story.isMine,
                    onDelete: () => _confirmDelete(story),
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
