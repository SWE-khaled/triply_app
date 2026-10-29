import 'package:cloud_firestore/cloud_firestore.dart';
import '../remote/firestore_service.dart';

/// Represents a tourist user as seen by the admin dashboard.
class AdminTourist {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String type; // Always 'Tourist'
  final String activity;
  final String status; // 'active' | 'suspended'
  final DateTime? createdAt;

  const AdminTourist({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.type = 'Tourist',
    this.activity = 'Tourist',
    required this.status,
    this.createdAt,
  });

  factory AdminTourist.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final name = (data['fullName'] as String?) ??
        (data['name'] as String?) ??
        (data['displayName'] as String?) ??
        'Tourist';
    final email = (data['email'] as String?) ?? '';
    final phone = (data['phone'] as String?) ?? '';
    final status = (data['status'] as String?) ?? 'active';

    String activity = 'Tourist';
    if (data['activity'] is String && (data['activity'] as String).isNotEmpty) {
      activity = data['activity'] as String;
    } else if (data['createdAt'] is Timestamp) {
      final date = (data['createdAt'] as Timestamp).toDate();
      activity = 'Joined ${date.day}/${date.month}/${date.year}';
    }

    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    return AdminTourist(
      uid: doc.id,
      name: name,
      email: email,
      phone: phone,
      type: 'Tourist',
      activity: activity,
      status: status,
      createdAt: createdAt,
    );
  }
}

/// Repository for managing tourist users from Firestore in the admin dashboard.
class AdminTouristsRepository {
  AdminTouristsRepository({FirestoreService? firestore})
      : _firestore = firestore ?? FirestoreService();

  static const String usersCollection = 'users';
  final FirestoreService _firestore;

  /// Fetches tourists (users where role != 'guide').
  Future<List<AdminTourist>> fetchTourists() async {
    try {
      final snapshot = await _firestore.collection(usersCollection).get();
      return snapshot.docs
          .where((doc) {
            final role = doc.data()['role'] as String?;
            return role != 'guide';
          })
          .map((doc) => AdminTourist.fromDoc(doc))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Real-time stream of tourists from Firestore.
  Stream<List<AdminTourist>> watchTourists() {
    return _firestore
        .collection(usersCollection)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final role = doc.data()['role'] as String?;
                return role != 'guide';
              })
              .map((doc) => AdminTourist.fromDoc(doc))
              .toList();
        });
  }

  /// Toggles tourist status between 'active' and 'suspended'.
  Future<bool> updateStatus(String uid, String newStatus) async {
    try {
      await _firestore.writeDoc(usersCollection, uid, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

