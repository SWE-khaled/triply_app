import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/admin_session.dart';
part 'admin_auth_state.dart';

/// Admin authentication, backed by Firebase Auth.
///
/// The access rule is the `role` field of the signed-in user's Firestore
/// document - not an email pattern - and the security rules enforce it
/// again on every write.
///
/// The very first account of a fresh project may claim the admin role
/// itself (the rules allow it while the project has no admin yet).
/// Afterwards an existing admin has to hand the role out.
class AdminAuthCubit extends Cubit<AdminAuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AdminAuthCubit({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance,
      super(const AdminAuthInitial());

  /// Restores an existing session (used when entering the dashboard
  /// with an already-authenticated admin).
  AdminAuthCubit.authenticated(AdminSession session)
    : _auth = FirebaseAuth.instance,
      _db = FirebaseFirestore.instance,
      super(AdminAuthSuccess(session: session));

  static const String accessDeniedMessage =
      'You are not allowed to access the Admin Dashboard.';

  static const String alreadyAnAdminMessage =
      'This project already has an admin. Ask that admin to set your role.';

  /// The signed-in admin, or null.
  AdminSession? get session => switch (state) {
    AdminAuthSuccess(:final session) => session,
    _ => null,
  };

  /// Whether a login / sign-up is running.
  bool get isLoading => state is AdminAuthLoading;

  /// The message of the last failure, or null.
  String? get errorMessage => switch (state) {
    AdminAuthError(:final error) => error,
    _ => null,
  };

  Future<bool> login({required String email, required String password}) async {
    emit(const AdminAuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      final role = await _roleOf(uid);
      if (role != 'admin') {
        await _auth.signOut();
        emit(AdminAuthError(error: accessDeniedMessage));
        return false;
      }
      final name = credential.user!.displayName?.trim() ?? '';
      emit(
        AdminAuthSuccess(
          session: AdminSession(
            name: name.isNotEmpty ? name : email.split('@').first,
            email: email.trim(),
          ),
        ),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      emit(AdminAuthError(error: _authMessage(e)));
      return false;
    } catch (e) {
      emit(AdminAuthError(error: e.toString()));
      return false;
    }
  }

  Future<bool> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AdminAuthLoading());
    try {
      if (name.trim().isEmpty) {
        emit(AdminAuthError(error: 'Please enter your full name.'));
        return false;
      }
      if (password.length < 6) {
        emit(AdminAuthError(error: 'Password must be at least 6 characters.'));
        return false;
      }
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(name.trim());
      // Claim the admin role - allowed while the project has no admin.
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': 'admin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Close the bootstrap window: from now on only an admin can hand
      // the role out.
      await _db.collection('appSettings').doc('_bootstrap').set({
        'firstAdminUid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(
        AdminAuthSuccess(
          session: AdminSession(name: name.trim(), email: email.trim()),
        ),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      emit(AdminAuthError(error: _authMessage(e)));
      return false;
    } on FirebaseException {
      // The rules refused the admin role: somebody else already claimed it.
      emit(AdminAuthError(error: alreadyAnAdminMessage));
      return false;
    } catch (e) {
      emit(AdminAuthError(error: e.toString()));
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    emit(const AdminAuthLoggedOut());
  }

  void clearError() {
    emit(const AdminAuthInitial());
  }

  /// The role stored on the user's Firestore document.
  Future<String?> _roleOf(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'This email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}
