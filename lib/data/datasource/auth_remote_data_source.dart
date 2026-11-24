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
  Future<UserModel> registerWithEmailPassword(String email, String password, String displayName);
  Future<UserModel> signInAnonymously();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final StreamController<UserModel?> _authController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;
  bool _isFirebaseAvailable = false;

  static const String _prefKeyUid = 'auth_session_uid';
  static const String _prefKeyEmail = 'auth_session_email';
  static const String _prefKeyName = 'auth_session_name';
  static const String _prefKeyIsAnon = 'auth_session_is_anon';

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
      }
    } catch (e) {
      _isFirebaseAvailable = false;
      debugPrint('Firebase check: $e');
    }
  }

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_prefKeyUid);
      final email = prefs.getString(_prefKeyEmail);
      final name = prefs.getString(_prefKeyName);
      final isAnon = prefs.getBool(_prefKeyIsAnon) ?? false;

      if (uid != null && email != null) {
        _currentUser = UserModel(
          uid: uid,
          email: email,
          displayName: name ?? email.split('@').first,
          isAnonymous: isAnon,
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
      await prefs.setString(_prefKeyUid, user.uid);
      await prefs.setString(_prefKeyEmail, user.email);
      await prefs.setString(_prefKeyName, user.displayName);
      await prefs.setBool(_prefKeyIsAnon, user.isAnonymous);
    } catch (e) {
      debugPrint('Error persisting session: $e');
    }
  }

  Future<void> _clearPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyUid);
      await prefs.remove(_prefKeyEmail);
      await prefs.remove(_prefKeyName);
      await prefs.remove(_prefKeyIsAnon);
    } catch (e) {
      debugPrint('Error clearing session: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _authController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailPassword(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (_isFirebaseAvailable) {
      try {
        final usersCollection = FirebaseFirestore.instance.collection('users');

        // Query Firestore users collection for matching email
        var querySnapshot = await usersCollection.where('email', isEqualTo: cleanEmail).get();

        // Fallback for case-sensitive match if needed
        if (querySnapshot.docs.isEmpty) {
          querySnapshot = await usersCollection.where('email', isEqualTo: email.trim()).get();
        }

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final data = doc.data();
          final storedPassword = data['password']?.toString() ?? '';

          if (storedPassword != cleanPassword) {
            throw Exception('Incorrect password. Please verify your credentials.');
          }

          final name = data['name']?.toString() ?? email.split('@').first;
          final user = UserModel(
            uid: doc.id,
            email: data['email']?.toString() ?? cleanEmail,
            displayName: name,
            isAnonymous: false,
          );

          // Attempt FirebaseAuth sign-in in sync if available
          try {
            await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
              email: cleanEmail,
              password: cleanPassword,
            );
          } catch (_) {}

          _currentUser = user;
          await _persistSession(user);
          _authController.add(user);
          return user;
        } else {
          // Check if user exists in FirebaseAuth
          try {
            final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
              email: cleanEmail,
              password: cleanPassword,
            );
            final fbUser = cred.user!;
            final user = UserModel(
              uid: fbUser.uid,
              email: fbUser.email ?? cleanEmail,
              displayName: fbUser.displayName ?? cleanEmail.split('@').first,
              isAnonymous: false,
            );

            // Sync into Firestore 'users' collection with the expected structure
            await usersCollection.doc(user.uid).set({
              'email': cleanEmail,
              'name': user.displayName,
              'password': cleanPassword,
            }, SetOptions(merge: true));

            _currentUser = user;
            await _persistSession(user);
            _authController.add(user);
            return user;
          } catch (authError) {
            throw Exception('No user found with email "$email". Please register first.');
          }
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(e.toString());
      }
    }

    // Resilient simulated fallback if Firebase is offline
    await Future.delayed(const Duration(milliseconds: 500));
    final fallbackUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      displayName: cleanEmail.split('@').first,
      isAnonymous: false,
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
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();
    final cleanName = displayName.trim().isNotEmpty ? displayName.trim() : cleanEmail.split('@').first;

    if (_isFirebaseAvailable) {
      try {
        final usersCollection = FirebaseFirestore.instance.collection('users');

        // Check if user with this email already exists in Firestore
        final existing = await usersCollection.where('email', isEqualTo: cleanEmail).get();
        if (existing.docs.isNotEmpty) {
          throw Exception('An account with email "$email" already exists. Please sign in instead.');
        }

        String userId = '';
        // Try creating with FirebaseAuth as well
        try {
          final cred = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: cleanEmail,
            password: cleanPassword,
          );
          await cred.user?.updateDisplayName(cleanName);
          userId = cred.user?.uid ?? '';
        } catch (authErr) {
          debugPrint('FirebaseAuth registration info: $authErr');
        }

        // Write directly to Firestore 'users' collection with exact structure:
        // email: ""
        // name: ""
        // password: ""
        final userDocData = {
          'email': cleanEmail,
          'name': cleanName,
          'password': cleanPassword,
        };

        if (userId.isNotEmpty) {
          await usersCollection.doc(userId).set(userDocData);
        } else {
          final newDoc = await usersCollection.add(userDocData);
          userId = newDoc.id;
        }

        final user = UserModel(
          uid: userId,
          email: cleanEmail,
          displayName: cleanName,
          isAnonymous: false,
        );

        _currentUser = user;
        await _persistSession(user);
        _authController.add(user);
        return user;
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception(e.toString());
      }
    }

    // Fallback mode if offline
    await Future.delayed(const Duration(milliseconds: 500));
    final fallbackUser = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      displayName: cleanName,
      isAnonymous: false,
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
        final fbUser = cred.user!;
        final user = UserModel(
          uid: fbUser.uid,
          email: 'guest_${fbUser.uid.substring(0, 5)}@crypto.app',
          displayName: 'Guest Trader',
          isAnonymous: true,
        );
        _currentUser = user;
        await _persistSession(user);
        _authController.add(user);
        return user;
      } catch (e) {
        debugPrint('Firebase anon sign in error: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final user = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@crypto.app',
      displayName: 'Guest Trader',
      isAnonymous: true,
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
}
