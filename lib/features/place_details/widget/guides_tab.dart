import 'package:flutter/material.dart';

import '../model/guide.dart';
import 'guide_card.dart';

class GuidesTab extends StatelessWidget {
  final List<Guide> guides;
  final void Function(Guide guide)? onGuideTap;

  const GuidesTab({super.key, required this.guides, this.onGuideTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: guides
          .map(
            (g) => GuideCard(
              guide: g,
              onTap: onGuideTap == null ? null : () => onGuideTap!(g),
            ),
          )
          .toList(),
    );
  }
}
