import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triply/features/support/contact_us/model/contact_message_model.dart';

void main() {
  group('ContactMessageModel', () {
    test('maps a Firestore document including server timestamps', () {
      final createdAt = DateTime(2026, 11, 22, 10, 30);
      final model = ContactMessageModel.fromDocument(
        <String, dynamic>{
          'id': 'message-1',
          'userId': 'uid-1',
          'userName': 'Test Guide',
          'userEmail': 'guide@example.com',
          'userRole': 'tourGuide',
          'message': 'A detailed support request.',
          'type': 'complaint',
          'status': 'inProgress',
          'createdAt': Timestamp.fromDate(createdAt),
          'updatedAt': Timestamp.fromDate(createdAt),
        },
        'fallback-id',
      );

      expect(model.id, 'message-1');
      expect(model.userId, 'uid-1');
      expect(model.userRole, 'tourGuide');
      expect(model.type, 'complaint');
      expect(model.status, 'inProgress');
      expect(model.createdAt, createdAt);
      expect(model.updatedAt, createdAt);
    });

    test('leaves timestamp injection to the repository', () {
      final map = const ContactMessageModel(
        id: 'message-2',
        userId: 'uid-2',
        userRole: 'tourist',
        message: 'A detailed inquiry.',
        type: 'inquiry',
      ).toMap();

      expect(map['id'], 'message-2');
      expect(map['status'], 'pending');
      expect(map['type'], 'inquiry');
      expect(map.containsKey('createdAt'), isFalse);
      expect(map.containsKey('updatedAt'), isFalse);
    });
  });
}
