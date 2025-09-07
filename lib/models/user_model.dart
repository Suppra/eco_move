class UserModel {
  final String id;
  final String name;
  final String email;
  final String document;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.document,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'document': document,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      document: map['document'] ?? '',
    );
  }
}