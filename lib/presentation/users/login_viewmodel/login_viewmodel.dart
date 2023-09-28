import 'package:cloud_firestore/cloud_firestore.dart';

class LoginViewModel {
  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }
}