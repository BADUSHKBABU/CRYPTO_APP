import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl();

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  UserEntity? get currentUser => remoteDataSource.currentUser;

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) async {
    return await remoteDataSource.signInWithEmailPassword(email, password);
  }

  @override
  Future<UserEntity> registerWithEmailPassword(String email, String password, String displayName) async {
    return await remoteDataSource.registerWithEmailPassword(email, password, displayName);
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    return await remoteDataSource.signInAnonymously();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}

