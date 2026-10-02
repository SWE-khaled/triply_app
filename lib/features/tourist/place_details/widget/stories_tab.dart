import 'package:flutter/material.dart';

import '../model/story.dart';
import 'story_card.dart';

class StoriesTab extends StatelessWidget {
  final List<Story> stories;
  final void Function(Story story)? onStoryTap;

  const StoriesTab({super.key, required this.stories, this.onStoryTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stories
          .map(
            (s) => StoryCard(
              story: s,
              onTap: onStoryTap == null ? null : () => onStoryTap!(s),
            ),
          )
          .toList(),
    );
  }
}
