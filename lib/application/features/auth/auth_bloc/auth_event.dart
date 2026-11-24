import '../../../../domain/entities/user_entity.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

class AuthGuestSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserChangedEvent extends AuthEvent {
  final UserEntity? user;
  AuthUserChangedEvent(this.user);
}
