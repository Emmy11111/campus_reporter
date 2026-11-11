import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/enums.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _authSubscription = _service.authChanges.listen(_handleAuthChange);
  }

  final AuthService _service;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _profileSubscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _busy = false;
  bool _registering = false;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get busy => _busy;
  String? get error => _error;

  void _handleAuthChange(User? firebaseUser) {
    _profileSubscription?.cancel();
    _profileSubscription = null;

    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _profileSubscription = _service.watchProfile(firebaseUser.uid).listen(
      (profile) async {
        if (profile == null) {
          if (!_registering) {
            final email = firebaseUser.email ?? '';
            final fallback = AppUser(
              uid: firebaseUser.uid,
              name: firebaseUser.displayName ??
                  (email.isEmpty ? 'Student' : email.split('@').first),
              email: email,
              role: UserRole.student,
              createdAt: DateTime.now(),
            );
            try {
              await _service.createProfile(fallback);
            } catch (_) {
              await _service.signOut();
            }
          }
          return;
        }
        _user = profile;
        _status = AuthStatus.authenticated;
        notifyListeners();
      },
      onError: (_) => _service.signOut(),
    );
  }

  Future<bool> signIn(String email, String password) async {
    _error = null;
    _setBusy(true);
    try {
      await _service.signIn(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageFor(e);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setBusy(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String department,
  }) async {
    _error = null;
    _registering = true;
    _setBusy(true);
    try {
      await _service.register(
        name: name,
        email: email,
        password: password,
        department: department,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _messageFor(e);
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _registering = false;
      _setBusy(false);
    }
  }

  Future<void> signOut() => _service.signOut();

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}