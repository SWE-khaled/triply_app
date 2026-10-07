import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../data/mock/d_mock_places.dart';
import '../../d_home/view/d_home_view.dart';

/// User Posts management screen — grid of post cards.
class UserPostsView extends StatefulWidget {
  const UserPostsView({super.key});

  @override
  State<UserPostsView> createState() => _UserPostsViewState();
}

class _UserPostsViewState extends State<UserPostsView> {
  final TextEditingController _search = TextEditingController();
  late List<MockPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = List.from(mockPosts);
  }

  void _removePost(MockPost post) {
    setState(() {
      _posts.remove(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CardSectionHeader(
                    title: 'Manage User Posts',
                    subtitle: 'Search, review, edit and control all user posts.',
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search user posts...',
              controller: _search,
            ),
            const SizedBox(height: 24),

            // Posts grid
            LayoutBuilder(
              builder: (context, constraints) {
                final cardW = (constraints.maxWidth - 32) / 3;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _posts
                      .map((p) => SizedBox(
                            width: cardW,
                            child: _PostCard(
                              post: p,
                              onRemove: () => _removePost(p),
                              onView: () => _viewPost(p),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewPost(MockPost post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(post.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(post.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50)),
            const SizedBox(height: 16),
            Text('Author: ${post.author}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This is a great post about a trip! Here would be the full content.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final MockPost post;
  final VoidCallback onRemove;
  final VoidCallback onView;
  const _PostCard({required this.post, required this.onRemove, required this.onView});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              post.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: AppColors.statBadgeBg.withValues(alpha: 1.0),
                child: const Icon(Icons.image_outlined,
                    size: 48, color: AppColors.textMuted),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AppTextStyles.postCardTitle),
                const SizedBox(height: 4),
                Text('By ${post.author}', style: AppTextStyles.postCardAuthor),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onView,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'View',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.buttonSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: onRemove,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Remove',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.buttonDanger,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

