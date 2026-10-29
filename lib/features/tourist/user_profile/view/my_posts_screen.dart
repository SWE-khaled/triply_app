import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/AuthTourist/cubit/auth_cubit.dart';
import 'package:triply/features/tourist/community/data/community_posts_repository.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'profile_screen.dart'
    show ProfilePostCard, deleteCommunityPost, shareProfilePost;

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});
  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late final Stream<List<CommunityPost>> _posts =
      FirestoreCommunityPostsRepository().watchMyPosts();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0.0,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Color(0xFF0E5865),
        ),
      ),
      title: const Text(
        'My posts',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF263A40),
        ),
      ),
    ),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(10, 8, 10, 14),
          child: Text(
            'Your published travel moments, all in one place. View or remove a post.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: Color(0xFF62777D),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<CommunityPost>>(
            stream: _posts,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'Could not load your posts. Please try again.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final posts = (snapshot.data ?? const <CommunityPost>[])
                  .where(
                    (post) =>
                        uid != null &&
                        post.authorId.isNotEmpty &&
                        post.authorId == uid,
                  )
                  .toList();
              if (posts.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'You have no published travel moments yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF62777D)),
                    ),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
                children: [
                  for (final post in posts) ...[
                    ProfilePostCard(
                      post: post,
                      compact: false,
                      authorAvatarUrl:
                          context.watch<AuthCubit>().user?.photoURL ?? '',
                      onDelete: () => deleteCommunityPost(context, post),
                      onShare: () => shareProfilePost(context, post),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 8, 2, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.location,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF62777D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => deleteCommunityPost(context, post),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0E5865),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "You're all caught up with your travel moments.",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF62777D),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
