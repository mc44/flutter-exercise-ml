import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel {
  String name = '';
  String number = '';
  String email = '';
  String role = '';

  void registerUser() {
    final userData = {
      'name': name,
      'number': number,
      'email': email,
      'role': role,
    };

    FirebaseFirestore.instance.collection('users').add(userData);
  }
}