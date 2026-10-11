// Phase 6 emulator probe: REAL Flutter SDK (Auth + Firestore) against the
// LOCAL emulator suite (auth 9099 + firestore 8090 + functions 5001 for the
// like-aggregate trigger). Run ONLY via:
//   flutter run -d chrome --target tool/phase6_emu_probe.dart
//     --dart-define=TRIPLY_EMULATOR_HOST=127.0.0.1:8090
//     --dart-define=TRIPLY_EMULATOR_AUTH_HOST=127.0.0.1:9099
//     --dart-define=TRIPLY_EMULATOR_PROJECT=demo-phase6
//     --web-browser-flag=--headless=new
//
// (See tool/phase1_emu_probe.dart for why `flutter run` is required.)
// Isolation: DEFAULT app with demo options + emulator overrides applied
// BEFORE any Firebase use. Fixtures come from the out-of-repo
// phase6-seed.js (fixed uids). Production (DefaultFirebaseOptions /
// triply-f9b82) is never referenced here. Push delivery is NOT claimed:
// there is no FCM transport in the app; only Firestore records are read.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:triply/core/firebase/firestore_result.dart';
import 'package:triply/data/firestore/repositories/community_repository.dart';
import 'package:triply/features/tour_guide/homeandNotificationTr/cubit/guide_notifications_cubit.dart';
import 'package:triply/features/tourist/community/cubit/community_cubit.dart';
import 'package:triply/features/tourist/community/model/community_post.dart';
import 'package:triply/features/tourist/notifications/cubit/notifications_cubit.dart';

const _fsHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_HOST',
  defaultValue: '127.0.0.1:8090',
);
const _authHost = String.fromEnvironment(
  'TRIPLY_EMULATOR_AUTH_HOST',
  defaultValue: '127.0.0.1:9099',
);
const _project = String.fromEnvironment(
  'TRIPLY_EMULATOR_PROJECT',
  defaultValue: 'demo-phase6',
);

int _pass = 0;
int _fail = 0;

void _check(String name, bool ok, [String detail = '']) {
  if (ok) {
    _pass++;
    debugPrint('PROBE_PASS $name $detail');
  } else {
    _fail++;
    debugPrint('PROBE_FAIL $name $detail');
  }
}

String _err(Object e) {
  const prefix = 'Exception: ';
  final t = e.toString();
  return t.startsWith(prefix) ? t.substring(prefix.length) : t;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Emulator overrides BEFORE any Firebase use.
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'emulator-only',
        appId: '1:1:web:1',
        messagingSenderId: '1',
        projectId: _project,
      ),
    );
    final authHostParts = _authHost.split(':');
    await FirebaseAuth.instance.useAuthEmulator(
      authHostParts[0],
      int.parse(authHostParts[1]),
    );
    FirebaseFirestore.instance.settings = Settings(
      host: _fsHost,
      sslEnabled: false,
      persistenceEnabled: false,
    );
    debugPrint('PROBE_INFO project=$_project fs=$_fsHost');

    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'cusera@test.dev',
      password: 'pass1234',
    );
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final communityRepo = CommunityRepository();

    // 1. Live feed through the real repository (seeded docs only).
    final feed = await communityRepo.feed(uid);
    final feedIds = feed is FirestoreOk<List<CommunityPost>>
        ? feed.data.map((p) => p.id).toList()
        : <String>[];
    _check(
      'feed-live',
      feedIds.toSet().containsAll(['feed-1', 'feed-mine-1']),
      feedIds.join(','),
    );

    // 2. Cubit refresh replaces mocks; mine resolves; expired excluded.
    final cubit = CommunityCubit(uid: uid);
    final ok = await cubit.refreshRemote();
    final ids = cubit.posts.map((p) => p.id).toList();
    final stories = [
      ...cubit.userRings.map((s) => s.id),
      ...cubit.myStories.map((s) => s.id),
    ];
    _check(
      'cubit-refresh',
      ok &&
          ids.toSet().containsAll(['feed-1', 'feed-mine-1']) &&
          !stories.contains('expired-1') &&
          stories.contains('active-1'),
      'posts=${ids.join(',')} stories=${stories.join(',')}',
    );
    final mine = cubit.posts.firstWhere((p) => p.id == 'feed-mine-1');
    _check('mine-flag', mine.isMine == true);

    // 3. Text post persists and reloads with a server id.
    final newId = await cubit.createPost(
      text: 'Probe post',
      imagePaths: const [],
      location: 'Cairo',
      authorName: 'C User',
      authorAvatarUrl: '',
    );
    await cubit.refreshRemote();
    _check(
      'create-post',
      newId.isNotEmpty && cubit.posts.any((p) => p.id == newId && p.isMine),
      newId,
    );

    // 4. Image posts refused without touching the backend.
    try {
      await cubit.createPost(
        text: 'pics',
        imagePaths: const ['/tmp/a.jpg'],
        authorName: 'C User',
        authorAvatarUrl: '',
      );
      _check('image-post-blocked', false, 'unexpected success');
    } catch (e) {
      _check(
        'image-post-blocked',
        _err(e).contains('uploads are not available'),
        _err(e),
      );
    }

    // 5. Persistent like: doc exists; aggregate follows via trigger.
    final target = cubit.posts.firstWhere((p) => p.id == 'feed-1');
    final liked = await cubit.toggleLikePersistent(target);
    final likeDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc('feed-1')
        .collection('likes')
        .doc(uid)
        .get();
    var count = -1;
    for (var i = 0; i < 30; i++) {
      final snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc('feed-1')
          .get();
      count = (snap.data()?['likesCount'] as num?)?.toInt() ?? -1;
      if (count == 1) break;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    _check(
      'like-persists',
      liked && likeDoc.exists && count == 1,
      'count=$count',
    );
    await cubit.toggleLikePersistent(target);
    var count2 = -1;
    for (var i = 0; i < 30; i++) {
      final snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc('feed-1')
          .get();
      count2 = (snap.data()?['likesCount'] as num?)?.toInt() ?? -1;
      if (count2 == 0) break;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    _check('unlike-reconciles', count2 == 0, 'count=$count2');

    // 6. Own post deletes; others rejected before any write.
    try {
      await cubit.deletePostRemote(
        cubit.posts.firstWhere((p) => p.id == 'feed-1'),
      );
      _check('delete-others-blocked', false, 'unexpected success');
    } catch (e) {
      _check('delete-others-blocked', _err(e).isNotEmpty, _err(e));
    }
    await cubit.deletePostRemote(
      cubit.posts.firstWhere((p) => p.id == 'feed-mine-1'),
    );
    await cubit.refreshRemote();
    _check('delete-own', cubit.posts.every((p) => p.id != 'feed-mine-1'));

    // 7. Server story delete persists.
    await cubit.deleteStoryRemote(
      cubit.myStories.firstWhere((s) => s.id == 'mine-s1'),
    );
    await cubit.refreshRemote();
    _check('delete-story', cubit.myStories.every((s) => s.id != 'mine-s1'));
    await cubit.close();

    // 8. Notifications: own only, sections, read persistence.
    final ncubit = NotificationsCubit();
    final nok = await ncubit.loadRemote(uid);
    final nids = ncubit.state.items.map((n) => n.id).toList();
    _check(
      'notif-list',
      nok && nids.toSet().containsAll(['cn1', 'cn2']) && !nids.contains('cn3'),
      nids.join(','),
    );
    _check('notif-unread', ncubit.unreadCount == 2);
    _check(
      'notif-sections',
      ncubit.today.any((n) => n.id == 'cn1') &&
          ncubit.earlier.any((n) => n.id == 'cn2'),
    );
    await ncubit.markOneReadRemote(uid, 'cn1');
    final n1 = await FirebaseFirestore.instance
        .collection('notifications')
        .doc('cn1')
        .get();
    _check('notif-mark-one', n1.data()?['isRead'] == true);
    await ncubit.markAllReadRemote(uid);
    final n2 = await FirebaseFirestore.instance
        .collection('notifications')
        .doc('cn2')
        .get();
    _check(
      'notif-mark-all',
      n2.data()?['isRead'] == true && ncubit.unreadCount == 0,
    );
    await ncubit.close();

    // 9. Guide notifications through the real repository.
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'cguide1@test.dev',
      password: 'pass1234',
    );
    final guideUid = FirebaseAuth.instance.currentUser!.uid;
    final gcubit = GuideNotificationsCubit();
    final gok = await gcubit.loadRemote(guideUid);
    _check('guide-list', gok && gcubit.state.items.any((n) => n.id == 'gn1'));
    await gcubit.markOneReadRemote('gn1');
    final gn1 = await FirebaseFirestore.instance
        .collection('notifications')
        .doc('gn1')
        .get();
    _check('guide-mark-read', gn1.data()?['isRead'] == true);
    await gcubit.close();

    // 10. Unauthenticated post create denied by rules.
    await FirebaseAuth.instance.signOut();
    try {
      await communityRepo.addPost(authorId: 'anon', text: 'x');
      _check('unauth-create-denied', false, 'unexpected success');
    } catch (e) {
      _check('unauth-create-denied', true, _err(e));
    }

    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  } catch (e) {
    debugPrint('PROBE_FATAL $e');
    debugPrint('PROBE_DONE pass=$_pass fail=$_fail');
  }
}
