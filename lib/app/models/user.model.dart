import 'dart:convert';

class User {
  String userID;
  String userName;
  List modelData;

  User({
    required this.userID,
    required this.userName,
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      userID: user["userID"],
      userName: user['user'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toMap() {
    return {
      'userID': userID,
      'user': userName,
      'model_data': jsonEncode(modelData),
    };
  }
}
