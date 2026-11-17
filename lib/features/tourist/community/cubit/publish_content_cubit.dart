import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:triply/core/utils/safe_emit_mixin.dart';

import '../data/community_posts_repository.dart';
import '../data/community_stories_repository.dart';
import '../model/community_post.dart';
import '../model/community_story.dart';
import 'community_action_error.dart';
import 'publish_content_state.dart';

/// Owns the "share a story / share a post" write operations.
///
/// The feed cubits own the resulting snapshots; this cubit only reports the
/// outcome so the View can show feedback.
class PublishContentCubit extends Cubit<PublishContentState>
    with SafeEmitMixin<PublishContentState> {
  PublishContentCubit({
    CommunityPostsRepository? postsRepository,
    CommunityStoriesRepository? storiesRepository,
    this.onPostPublished,
    this.onStoryPublished,
  }) : _postsRepository =
            postsRepository ?? FirestoreCommunityPostsRepository(),
        _storiesRepository =
            storiesRepository ?? FirestoreCommunityStoriesRepository(),
        super(const PublishInitial());

  final CommunityPostsRepository _postsRepository;
  final CommunityStoriesRepository _storiesRepository;

  /// Feed hooks that restore the old optimistic insertion behavior without
  /// letting this cubit write another cubit's state.
  final void Function(CommunityPost post)? onPostPublished;
  final void Function(CommunityStory story)? onStoryPublished;

  /// Uploads the story image and writes Firestore metadata. A null image (the
  /// user dismissed the picker) is a silent no-op, as before.
  Future<CommunityStory?> publishStory(XFile? image) async {
    if (image == null) return null;
    safeEmit(const PublishingContent());
    try {
      final story = await _storiesRepository.createStory(image);
      onStoryPublished?.call(story);
      safeEmit(ContentPublished(story: story));
      return story;
    } catch (error) {
      safeEmit(PublishFailed(message: communityActionErrorMessage(error)));
      return null;
    }
  }

  /// Uploads the selected media, then creates the Firestore document.
  Future<CommunityPost?> publishPost({
    required List<XFile> images,
    required String text,
    String? location,
  }) async {
    safeEmit(const PublishingContent());
    try {
      final post = await _postsRepository.createPost(
        images: images,
        text: text,
        location: location,
      );
      onPostPublished?.call(post);
      safeEmit(ContentPublished(post: post));
      return post;
    } catch (error) {
      safeEmit(PublishFailed(message: communityActionErrorMessage(error)));
      return null;
    }
  }
}
