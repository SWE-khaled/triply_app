import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/community_cubit.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../data/community_stories_repository.dart';
import '../model/community_story.dart';
import '../widget/story_progress_bars.dart';
import '../widget/story_viewer_header.dart';

/// Full-screen viewer for ONE user's stories only.
class StoryViewerScreen extends StatefulWidget {
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
  late List<CommunityStory> _stories;
  late int _currentIndex;
  Timer? _expiryTimer;
  bool _pruning = false;

  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _stories = widget.stories
        .where((story) => story.isDisplayableAt(_now))
        .toList();

    if (_stories.isEmpty) {
      _currentIndex = 0;
      _pageController = PageController();
      _progressController = AnimationController(
        vsync: this,
        duration: _storyDuration,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _closeIfEmpty());
    } else {
      _currentIndex = widget.initialIndex.clamp(0, _stories.length - 1).toInt();
      _pageController = PageController(initialPage: _currentIndex);
      _progressController =
          AnimationController(vsync: this, duration: _storyDuration)
            ..addStatusListener(_onProgressStatus)
            ..forward();
    }

    _expiryTimer = Timer.periodic(
      _expiryCheckInterval,
      (_) => _removeExpiredStories(),
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
      _removeExpiredStories();
    }
  }

  void _closeIfEmpty() {
    if (!mounted || _stories.isNotEmpty) return;
    _progressController.stop();
    Navigator.of(context).maybePop();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNext();
    }
  }

  void _goToNext() {
    if (_stories.isEmpty) return;
    if (_currentIndex < _stories.length - 1) {
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
    if (index < 0 || index >= _stories.length) return;
    if (!_stories[index].isDisplayableAt(_now)) {
      _removeExpiredStories();
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

  /// Removes expired Stories from the snapshot list. If the current Story
  /// expired, advance to the next active one or close the viewer.
  void _removeExpiredStories() {
    if (!mounted || _pruning || _stories.isEmpty) return;
    _pruning = true;
    try {
      final active = _stories
          .where((story) => story.isDisplayableAt(_now))
          .toList(growable: false);
      if (active.length == _stories.length) return;

      if (active.isEmpty) {
        _stories = active;
        _expiryTimer?.cancel();
        _progressController.stop();
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) => _closeIfEmpty());
        return;
      }

      final currentId = _stories[_currentIndex].id;
      final currentIndexInActive = active.indexWhere(
        (story) => story.id == currentId,
      );

      if (currentIndexInActive >= 0) {
        // The viewed Story is still active; only older pages disappeared.
        _stories = active;
        _currentIndex = currentIndexInActive;
        setState(() {});
        if (_pageController.hasClients &&
            _pageController.page?.round() != _currentIndex) {
          _pageController.jumpToPage(_currentIndex);
        }
        return;
      }

      // The viewed Story expired. Find the next active Story that followed
      // it; if there is none, close instead of falling back to an old Story.
      CommunityStory? next;
      for (var i = _currentIndex + 1; i < _stories.length; i++) {
        final candidate = _stories[i];
        if (active.any((story) => story.id == candidate.id)) {
          next = candidate;
          break;
        }
      }

      if (next == null) {
        // The viewed Story expired and there is no later active Story:
        // close instead of falling back to an older page.
        _stories = const [];
        _expiryTimer?.cancel();
        _progressController.stop();
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) => _closeIfEmpty());
        return;
      }

      _stories = active;
      _currentIndex = active.indexWhere((story) => story.id == next!.id);
      setState(() {});
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
      _progressController
        ..reset()
        ..forward();
    } finally {
      _pruning = false;
    }
  }

  Widget _imageError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return const Icon(
      Icons.broken_image_outlined,
      color: Colors.white54,
      size: 48,
    );
  }

  String _deleteErrorMessage(Object error) {
    if (error is CommunityStoriesException) return error.message;
    return 'Could not delete this Story. Please try again.';
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

    try {
      await context.read<CommunityCubit>().deleteStory(story);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_deleteErrorMessage(error))));
      _resume();
      return;
    }

    if (!mounted) return;

    _stories.removeWhere((item) => item.id == story.id);

    if (_stories.isEmpty) {
      _progressController.stop();
      Navigator.of(context).pop();
      return;
    }

    if (_currentIndex >= _stories.length) {
      _currentIndex = _stories.length - 1;
    }

    setState(() {});

    _pageController.jumpToPage(_currentIndex);

    _progressController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    final story = _stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _stories.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final item = _stories[index];

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
                count: _stories.length,
                currentIndex: _currentIndex,
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
  }
}
