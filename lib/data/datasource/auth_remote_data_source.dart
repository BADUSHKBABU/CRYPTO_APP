import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  Future<UserModel> signInWithEmailPassword(String email, String password);
  Future<UserModel> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  );
  Future<UserModel> signInAnonymously();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final StreamController<UserModel?> _authController =
      StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  bool _isFirebaseAvailable = false;
  StreamSubscription<fb.User?>? _fbAuthSub;

  static const String _prefKeyEmail = 'auth_session_email';
  static const String _prefKeyName = 'auth_session_name';

  AuthRemoteDataSourceImpl() {
    _init();
  }

  Future<void> _init() async {
    await _checkFirebaseAvailability();
    await _loadSavedSession();
  }

  Future<void> _checkFirebaseAvailability() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isFirebaseAvailable = true;

        // Listen to Firebase Authentication state changes
        _fbAuthSub = fb.FirebaseAuth.instance.authStateChanges().listen((
          fbUser,
        ) {
          if (fbUser != null) {
            final user = UserModel(
              email: fbUser.email ?? '',
              name:
                  fbUser.displayName ??
                  (fbUser.email?.split('@').first ?? 'Trader'),
            );
            _currentUser = user;
            _persistSession(user);
            _authController.add(user);
          } else {
            if (_currentUser != null &&
                _currentUser!.email == 'guest@crypto.app') {
              // keep guest session
            } else {
              _currentUser = null;
              _clearPersistedSession();
              _authController.add(null);
            }
          }
        });
      }
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firebase check: $e');
    }
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_prefKeyEmail);
      final name = prefs.getString(_prefKeyName);

      if (email != null) {
        _currentUser = UserModel(
          email: email,
          name: name ?? email.split('@').first,
        );
        _authController.add(_currentUser);
      }
    } catch (e) {
      debugPrint('Error loading saved session: $e');
    }
  }

  Future<void> _persistSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyEmail, user.email);
      await prefs.setString(_prefKeyName, user.name);
    } catch (e) {
      debugPrint('Error persisting session: $e');
    }
  }

  Future<void> _clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyEmail);
      await prefs.remove(_prefKeyName);
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (_isFirebaseAvailable) {
      try {
        // 1. Sign in with Firebase Authentication
        final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );

        String name = cred.user?.displayName ?? cleanEmail.split('@').first;

        // 2. Sync / fetch user profile from Firestore 'users' collection
        try {
          final uid = cred.user?.uid ?? '';
          if (uid.isNotEmpty) {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .get();
            if (userDoc.exists) {
              name = userDoc.data()?['name']?.toString() ?? name;
            } else {
              // Ensure doc exists in Firestore as well
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .set({
                    'name': name,
                    'email': cleanEmail.toLowerCase(),
                    'password': cleanPassword,
                    'uid': uid,
                  }, SetOptions(merge: true));
            }
          }
        } catch (dbErr) {
          debugPrint('Firestore fetch notice: $dbErr');
        }

        final user = UserModel(
          email: cleanEmail,
          name: name,
          password: cleanPassword,
        );

        _currentUser = user;
        await _persistSession(user);
        _authController.add(user);
        return user;
      } on fb.FirebaseAuthException catch (e) {
        // Fallback: Check if user exists in Firestore 'users' collection
        try {
          final querySnap = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: cleanEmail.toLowerCase())
              .get();
          if (querySnap.docs.isNotEmpty) {
            final data = querySnap.docs.first.data();
            final storedPass = data['password']?.toString() ?? '';
            if (storedPass == cleanPassword) {
              final user = UserModel(
                email: cleanEmail,
                name: data['name']?.toString() ?? cleanEmail.split('@').first,
                password: cleanPassword,
              );
              _currentUser = user;
              await _persistSession(user);
              _authController.add(user);
              return user;
            } else {
              throw Exception(
                'Incorrect password. Please verify your credentials.',
              );
            }
          }
        } catch (dbErr) {
          if (dbErr is Exception &&
              dbErr.toString().contains('Incorrect password')) {
            rethrow;
          }
        }

        if (e.code == 'operation-not-allowed') {
          throw Exception(
            'Firebase Authentication is not enabled for Email/Password.\n'
            'In Firebase Console: Authentication > Sign-in method tab > Enable "Email/Password" and click Save.',
          );
        } else if (e.code == 'user-not-found') {
          throw Exception(
            'No user found with email "$email". Please register first.',
          );
        } else if (e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          throw Exception(
            'Incorrect password. Please verify your credentials.',
          );
        } else if (e.code == 'user-disabled') {
          throw Exception('This account has been disabled.');
        } else if (e.code == 'invalid-email') {
          throw Exception('Invalid email address format.');
        } else {
          throw Exception(e.message ?? 'Login error (${e.code})');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(e.toString());
      }
    }

    // Fallback mode if offline
    await Future.delayed(const Duration(milliseconds: 300));
    final fallbackUser = UserModel(
      password: cleanPassword,
      email: cleanEmail,
      name: cleanEmail.split('@').first,
    );
    _currentUser = fallbackUser;
    await _persistSession(fallbackUser);
    _authController.add(fallbackUser);
    return fallbackUser;
  }

  @override
  Future<UserModel> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    final cleanName = displayName.trim().isNotEmpty
        ? displayName.trim()
        : cleanEmail.split('@').first;

    if (_isFirebaseAvailable) {
      try {
        // 1. Create user in Firebase Authentication
        final cred = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: cleanEmail,
              password: cleanPassword,
            );

        await cred.user?.updateDisplayName(cleanName);
        final uid = cred.user?.uid ?? '';

        // 2. Also save to Firestore 'users' collection with your exact schema:
        // name: ""
        // email: ""
        // password: ""
        try {
          final usersCollection = FirebaseFirestore.instance.collection(
            'users',
          );
          final userDocData = {
            'name': cleanName,
            'email': cleanEmail.toLowerCase(),
            'password': cleanPassword,
            if (uid.isNotEmpty) 'uid': uid,
          };

          if (uid.isNotEmpty) {
            await usersCollection
                .doc(uid)
                .set(userDocData, SetOptions(merge: true));
          } else {
            await usersCollection.add(userDocData);
          }
        } catch (dbErr) {
          debugPrint('Firestore save notice: $dbErr');
        }

        final user = UserModel(
          password: cleanPassword,
          email: cleanEmail,
          name: cleanName,
        );

        _currentUser = user;
        await _persistSession(user);
        _authController.add(user);
        return user;
      } on fb.FirebaseAuthException catch (e) {
        // Fallback: Check if user exists in Firestore 'users' collection
        try {
          final querySnap = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: cleanEmail.toLowerCase())
              .get();
          if (querySnap.docs.isNotEmpty) {
            final data = querySnap.docs.first.data();
            final storedPass = data['password']?.toString() ?? '';
            if (storedPass == cleanPassword) {
              final user = UserModel(
                email: cleanEmail,
                name: data['name']?.toString() ?? cleanEmail.split('@').first,
                password: cleanPassword,
              );
              _currentUser = user;
              await _persistSession(user);
              _authController.add(user);
              return user;
            } else {
              throw Exception(
                'Incorrect password. Please verify your credentials.',
              );
            }
          }
        } catch (dbErr) {
          if (dbErr is Exception &&
              dbErr.toString().contains('Incorrect password')) {
            rethrow;
          }
        }

        if (e.code == 'operation-not-allowed') {
          throw Exception(
            'Firebase Authentication is not enabled for Email/Password.\n'
            'In Firebase Console: Authentication > Sign-in method tab > Enable "Email/Password" and click Save.',
          );
        } else if (e.code == 'email-already-in-use') {
          throw Exception(
            'An account with email "$email" already exists. Please sign in instead.',
          );
        } else if (e.code == 'weak-password') {
          throw Exception('Password must be at least 6 characters.');
        } else if (e.code == 'invalid-email') {
          throw Exception('The email address is invalid.');
        } else {
          throw Exception(e.message ?? 'Registration error (${e.code})');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(e.toString());
      }
    }

    // Fallback mode if offline
    await Future.delayed(const Duration(milliseconds: 300));
    final fallbackUser = UserModel(
      password: cleanPassword,
      email: cleanEmail,
      name: cleanName,
    );
    _currentUser = fallbackUser;
    await _persistSession(fallbackUser);
    _authController.add(fallbackUser);
    return fallbackUser;
  }

  @override
  Future<UserModel> signInAnonymously() async {
    if (_isFirebaseAvailable) {
      try {
        final cred = await fb.FirebaseAuth.instance.signInAnonymously();
        final user = UserModel(
          email: 'guest_${cred.user?.uid.substring(0, 5) ?? "0"}@crypto.app',
          password: 'guest',
          name: 'Guest Trader',
        );
        _currentUser = user;
        await _persistSession(user);
        _authController.add(user);
        return user;
      } catch (e) {
        debugPrint('Firebase anon sign-in notice: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final user = UserModel(
      email: 'guest@crypto.app',
      password: 'guest',
      name: 'Guest Trader',
    );
    _currentUser = user;
    await _persistSession(user);
    _authController.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      try {
        await fb.FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
    await _clearPersistedSession();
    _currentUser = null;
    _authController.add(null);
  }

  void dispose() {
    _fbAuthSub?.cancel();
    _authController.close();
  }
}
