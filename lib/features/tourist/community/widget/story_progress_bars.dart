import 'package:flutter/material.dart';

/// Top progress bars extracted from `story_viewer_view.dart:236`.
class StoryProgressBars extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Listenable progress;

  const StoryProgressBars({
    super.key,
    required this.count,
    required this.currentIndex,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                final double value;
                if (i < currentIndex) {
                  value = 1;
                } else if (i == currentIndex) {
                  value = (progress as Animation<double>).value;
                } else {
                  value = 0;
                }
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
