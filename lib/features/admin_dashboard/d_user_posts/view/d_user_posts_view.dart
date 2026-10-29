import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/data/repositories/admin_posts_repository.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../d_home/view/d_home_view.dart';

class UserPostsView extends StatefulWidget {
  const UserPostsView({super.key});

  @override
  State<UserPostsView> createState() => _UserPostsViewState();
}

class _UserPostsViewState extends State<UserPostsView> {
  final TextEditingController _search = TextEditingController();
  final AdminPostsRepository _repository = AdminPostsRepository();

  List<AdminPost> _posts = const [];
  StreamSubscription<List<AdminPost>>? _subscription;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repository.ensureInitialPostIfEmpty();
    _subscription = _repository.watchPosts().listen(
      (posts) {
        if (!mounted) return;
        setState(() {
          _posts = posts;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _loading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _search.dispose();
    super.dispose();
  }

  List<AdminPost> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _posts;
    return _posts.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.text.toLowerCase().contains(q) ||
          p.author.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _removePost(AdminPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete this post by ${post.author}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await _repository.deletePost(post.id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete post.')),
      );
    }
  }

  void _viewPost(AdminPost post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                post.title.isNotEmpty ? post.title : 'User Post',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPostImage(post.imageUrl, height: 220),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Author: ${post.author}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              if (post.location.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      post.location,
                      style: AppTextStyles.tableCellMuted,
                    ),
                  ],
                ),
              ],
              if (post.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Posted: ${post.createdAt!.day}/${post.createdAt!.month}/${post.createdAt!.year}',
                  style: AppTextStyles.tableCellMuted.copyWith(fontSize: 12),
                ),
              ],
              const SizedBox(height: 14),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 8),
              Text(
                post.text.isNotEmpty ? post.text : 'No text content in this post.',
                style: AppTextStyles.tableCell.copyWith(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _removePost(post);
            },
            icon: const Icon(Icons.delete, size: 16, color: Colors.white),
            label: const Text('Delete Post', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String url, {double height = 180}) {
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
      return Image.network(
        url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(height),
      );
    } else if (!kIsWeb && url.isNotEmpty) {
      try {
        if (File(url).existsSync()) {
          return Image.file(
            File(url),
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _imagePlaceholder(height),
          );
        }
      } catch (_) {}
    }
    return _imagePlaceholder(height);
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      color: AppColors.statBadgeBg,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.textMuted),
      ),
    );
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
                    subtitle: 'Search, review and control all live user posts.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SearchFilterRow(
              hintText: 'Search user posts...',
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No posts found.')),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet = constraints.maxWidth < 900;
                  final columns = isMobile ? 1 : (isTablet ? 2 : 3);
                  final cardW = (constraints.maxWidth - (16 * (columns - 1))) / columns;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _filtered
                        .map(
                          (p) => SizedBox(
                            width: cardW,
                            child: _PostCard(
                              post: p,
                              onRemove: () => _removePost(p),
                              onView: () => _viewPost(p),
                              imageBuilder: _buildPostImage,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final AdminPost post;
  final VoidCallback onRemove;
  final VoidCallback onView;
  final Widget Function(String, {double height}) imageBuilder;

  const _PostCard({
    required this.post,
    required this.onRemove,
    required this.onView,
    required this.imageBuilder,
  });

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
            child: imageBuilder(post.imageUrl, height: 180),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: AppTextStyles.postCardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${post.author}',
                  style: AppTextStyles.postCardAuthor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
