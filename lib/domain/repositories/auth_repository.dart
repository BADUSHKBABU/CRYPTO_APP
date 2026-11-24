import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> registerWithEmailPassword(String email, String password, String displayName);
  Future<UserEntity> signInAnonymously();
  Future<void> signOut();
}

