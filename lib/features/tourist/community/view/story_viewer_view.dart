import 'dart:io';

import 'package:flutter/material.dart';

import '../controller/community_controller.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../model/community_story.dart';
import '../widget/story_progress_bars.dart';
import '../widget/story_viewer_header.dart';

/// Full-screen viewer for ONE user's stories only.
class StoryViewerScreen extends StatefulWidget {
  final List<CommunityStory> stories;
  final int initialIndex;
  final CommunityController controller;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.controller,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen>
    with SingleTickerProviderStateMixin {
  static const _storyDuration = Duration(seconds: 5);

  late final PageController _pageController;
  late final AnimationController _progressController;
  late List<CommunityStory> _stories;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _stories = List<CommunityStory>.from(widget.stories);

    _currentIndex =
        widget.initialIndex.clamp(0, _stories.length - 1).toInt();

    _pageController = PageController(
      initialPage: _currentIndex,
    );

    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )
      ..addStatusListener(_onProgressStatus)
      ..forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goToNext();
    }
  }

  void _goToNext() {
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

 Future<void> _confirmDelete(CommunityStory story) async {
  _pause();

  final confirmed = await ConfirmDeleteDialog.show(
    context,
    title: 'Deleting story',
    content: 'Are you sure you want to delete this story?',
  );

  if (!confirmed) {
    _resume();
    return;
  }

  final deleted = widget.controller.deleteStory(story);

  if (!mounted) return;

  if (!deleted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "You can't delete others story"
                ),
      ),
    );

    _resume();
    return;
  }


  _stories.removeWhere(
    (s) => s.id == story.id,
  );

 
  if (_stories.isEmpty) {
    Navigator.of(context).pop();
    return;
  }


  if (_currentIndex >= _stories.length) {
    _currentIndex = _stories.length - 1;
  }


  setState(() {});

  _pageController.jumpToPage(
    _currentIndex,
  );

  _progressController
    ..reset()
    ..forward();
}
  @override
  Widget build(BuildContext context) {
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

                    final width =
                        MediaQuery.of(context).size.width;

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
                          )
                        : Image.network(
                            item.imageUrl,
                            fit: BoxFit.contain,
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
                imageUrl: story.imageUrl,
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