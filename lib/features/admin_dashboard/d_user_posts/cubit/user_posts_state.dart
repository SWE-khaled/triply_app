part of 'user_posts_cubit.dart';

/// The state of the User Posts tab.
@immutable
sealed class UserPostsState {
  const UserPostsState();
}

/// Nothing has been requested yet.
final class UserPostsInitial extends UserPostsState {
  const UserPostsInitial();
}

/// The posts are being loaded for the first time.
final class UserPostsLoading extends UserPostsState {
  const UserPostsLoading();
}

/// The posts stream failed.
final class UserPostsError extends UserPostsState {
  final String message;

  const UserPostsError(this.message);
}

/// The live community posts, with the current search applied.
final class UserPostsSuccess extends UserPostsState {
  final List<CommunityPost> posts;
  final String query;

  const UserPostsSuccess({required this.posts, this.query = ''});

  List<CommunityPost> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return posts;
    return posts.where((post) {
      return postTitle(post).toLowerCase().contains(q) ||
          post.text.toLowerCase().contains(q) ||
          post.authorName.toLowerCase().contains(q);
    }).toList();
  }

  UserPostsSuccess copyWith({
    List<CommunityPost>? posts,
    String? query,
  }) {
    return UserPostsSuccess(
      posts: posts ?? this.posts,
      query: query ?? this.query,
    );
  }
}

/// The short title the admin tables show for a post.
String postTitle(CommunityPost post) {
  final text = post.text.trim();
  if (text.isNotEmpty) {
    return text.length > 40 ? '${text.substring(0, 37)}...' : text;
  }
  return 'Post by ${post.authorName}';
}
