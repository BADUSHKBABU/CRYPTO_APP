import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Stream<UserEntity?> get authStateChanges => repository.authStateChanges;
  UserEntity? get currentUser => repository.currentUser;

  Future<UserEntity> signIn(String email, String password) {
    return repository.signInWithEmailPassword(email, password);
  }

  Future<UserEntity> register(String email, String password, String displayName) {
    return repository.registerWithEmailPassword(email, password, displayName);
  }

  Future<UserEntity> signInAnonymously() {
    return repository.signInAnonymously();
  }

  Future<void> signOut() {
    return repository.signOut();
  }
}

