import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/tourist/community/model/community_story.dart';
import 'package:triply/features/tourist/community/widget/story_ring.dart';

void main() {
  test('reads legacy author names and avatar fields', () {
    final story = CommunityStory.fromDocument(
      {
        'createdAt': DateTime(2026, 11, 15, 10),
        'imageUrl': 'https://example.test/story.jpg',
        'user_name': 'Amina Hassan',
        'author_avatar_url': 'https://example.test/amina.jpg',
      },
      'story-1',
      now: DateTime(2026, 11, 15, 11),
    );

    expect(story?.authorName, 'Amina Hassan');
    expect(story?.authorAvatarUrl, 'https://example.test/amina.jpg');
  });

  testWidgets('story ring shows the author avatar and name', (tester) async {
    final story = CommunityStory(
      id: 'story-1',
      authorId: 'author-1',
      authorName: 'Amina Hassan',
      authorAvatarUrl: 'https://example.test/amina.jpg',
      imageUrl: 'https://example.test/story.jpg',
      createdAt: DateTime(2026, 11, 15, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StoryRing(story: story, ringColor: Colors.orange, onTap: () {}),
        ),
      ),
    );

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.foregroundImage, isA<NetworkImage>());
    expect(find.text('Amina Hassan'), findsOneWidget);
  });
}
