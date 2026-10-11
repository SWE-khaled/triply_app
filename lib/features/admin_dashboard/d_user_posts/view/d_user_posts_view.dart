import 'package:flutter/material.dart';
import '../../../../core/theme/d_app_colors.dart';
import '../../../../core/theme/d_app_text_styles.dart';
import '../../../../data/firestore/models/post_doc.dart';
import '../../../../data/firestore/repositories/admin_repository.dart';
import '../../d_home/view/d_home_view.dart';

/// User Posts management screen (server-backed).
///
/// Grid comes from the live community feed; Remove deletes through the
/// admin-allowed rules path and reloads. Cards show real post content —
/// never placeholder lorem text.
class UserPostsView extends StatefulWidget {
  const UserPostsView({super.key});

  @override
  State<UserPostsView> createState() => _UserPostsViewState();
}

class _UserPostsViewState extends State<UserPostsView> {
  final TextEditingController _search = TextEditingController();
  final AdminRepository _repo = AdminRepository();
  List<PostDoc> _posts = [];
  String _query = '';
  bool _loading = true;
  String? _error;
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Reloads the grid. Returns false (with [error] set) when the display
  /// may be stale — mutating callers surface a notice instead of a
  /// misleading success.
  Future<bool> _load() async {
    if (!mounted) return false;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await _repo.recentPosts();
      if (!mounted) return false;
      setState(() {
        _posts = posts;
        _loading = false;
      });
      return true;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _loading = false;
        _error = _message(e);
      });
      return false;
    }
  }

  static String _message(Object e) {
    const prefix = 'Exception: ';
    final text = e.toString();
    final msg = text.startsWith(prefix) ? text.substring(prefix.length) : text;
    return msg.isEmpty ? 'Operation failed. Please try again.' : msg;
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Card title derived from the real post text (posts carry no separate
  /// title field).
  static String _titleOf(PostDoc post) {
    final text = post.text.trim();
    if (text.isEmpty) return 'Untitled post';
    if (text.length <= 60) return text;
    return '${text.substring(0, 60)}…';
  }

  List<PostDoc> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _posts;
    return _posts.where((p) {
      return p.text.toLowerCase().contains(q) ||
          p.authorName.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _removePost(PostDoc post) async {
    if (_busy.contains(post.id)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Remove post'),
        content: const Text(
          'Are you sure you want to remove this post? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep post'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy.add(post.id));
    try {
      await _repo.deletePost(post.id);
      final fresh = await _load();
      _snack(
        fresh
            ? 'Post removed.'
            : 'Post removed, but the list could not refresh.',
      );
    } catch (e) {
      _snack(_message(e));
    } finally {
      if (mounted) setState(() => _busy.remove(post.id));
    }
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
                    subtitle:
                        'Search, review, edit and control all user posts.',
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

            // Posts grid
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null && _filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No posts found.')),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardW = (constraints.maxWidth - 32) / 3;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _filtered
                        .map(
                          (p) => SizedBox(
                            width: cardW,
                            child: _PostCard(
                              post: p,
                              busy: _busy.contains(p.id),
                              onRemove: () => _removePost(p),
                              onView: () => _viewPost(p),
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

  void _viewPost(PostDoc post) {
    final image = post.imageUrls.isNotEmpty ? post.imageUrls.first : '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_titleOf(post)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              Image.network(
                post.imageUrls.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 50),
              ),
            if (image.isNotEmpty) const SizedBox(height: 16),
            Text(
              'Author: ${post.authorName.isNotEmpty ? post.authorName : '—'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(post.text.isNotEmpty ? post.text : 'No text content.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final PostDoc post;
  final bool busy;
  final VoidCallback onRemove;
  final VoidCallback onView;
  const _PostCard({
    required this.post,
    required this.busy,
    required this.onRemove,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final image = post.imageUrls.isNotEmpty ? post.imageUrls.first : '';
    final title = post.text.trim().isEmpty
        ? 'Untitled post'
        : (post.text.trim().length <= 60
              ? post.text.trim()
              : '${post.text.trim().substring(0, 60)}…');
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
            child: image.isEmpty
                ? Container(
                    height: 180,
                    color: AppColors.statBadgeBg.withValues(alpha: 1.0),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : Image.network(
                    image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: AppColors.statBadgeBg.withValues(alpha: 1.0),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.postCardTitle),
                const SizedBox(height: 4),
                Text(
                  'By ${post.authorName.isNotEmpty ? post.authorName : '—'}',
                  style: AppTextStyles.postCardAuthor,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: busy ? null : onView,
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
                        onTap: busy ? null : onRemove,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: busy
                              ? const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Text(
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
