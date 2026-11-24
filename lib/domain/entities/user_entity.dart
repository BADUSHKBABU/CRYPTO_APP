class UserEntity {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });
}

