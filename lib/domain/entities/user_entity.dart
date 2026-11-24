class UserEntity {

  final String email;
  final String name;
  final String? password;
  // final bool isAnonymous;

  const UserEntity({
    // required this.uid,
    required this.email,
    required this.name,
    this.password,
    // this.isAnonymous = false,
  });
}

