import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Reads the signed-in account's role.
///
/// The chat entry points exist for tourists only; the rules enforce the
/// same rule on the server. A missing role falls back to `tourist`, which
/// matches how the app treats a user document without the field.
class ChatRoles {
  const ChatRoles._();

  static const String usersCollection = 'users';

  static Future<String?> currentUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(uid)
          .get();
      final role = doc.data()?['role'];
      if (role is String && role.isNotEmpty) return role;
      return 'tourist';
    } catch (_) {
      // Signed out, offline or refused: the button stays hidden.
      return null;
    }
  }

  static bool canStartChat(String? role) => role == 'tourist';
}
