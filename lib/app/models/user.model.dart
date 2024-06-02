import 'dart:convert';

class User {
  String userName;
  List modelData;

  User({
    required this.userName,
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      userName: user['user'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toMap() {
    return {
      'user': userName,
      'model_data': jsonEncode(modelData),
    };
  }
}
