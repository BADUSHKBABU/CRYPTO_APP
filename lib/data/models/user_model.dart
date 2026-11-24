import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    // required super.uid,
    required super.email,
    required super.name,
    super.password,
    // super.isAnonymous,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['name'] ?? '',
      password: json['password'],
      // isAnonymous: json['isAnonymous'] ?? false,
    );
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      // uid: id,
      email: data['email']?.toString() ?? '',
      name: data['name']?.toString() ?? data['name']?.toString() ?? '',
      password: data['password']?.toString(),
      // isAnonymous: data['isAnonymous'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'uid': uid,
      'email': email,
      'name': name,
      // 'displayName': displayName,
      'password': password,
      // 'isAnonymous': isAnonymous,
    };
  }
}
