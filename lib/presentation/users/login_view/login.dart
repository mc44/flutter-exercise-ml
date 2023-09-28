import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../equipment/view/equipment.dart';
import '../login_viewmodel/login_viewmodel.dart';

class LoginView extends StatelessWidget {
  final LoginViewModel viewModel = LoginViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: StreamBuilder(
        stream: viewModel.getUsers(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'An error occurred. Please try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey.shade400),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final user = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person),
                ),
                title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Role: ${user['role']}'),
                trailing: Text('ID: ${doc.id}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EquipmentList(
                        userId: doc.id,
                        userName: user['name'],
                        userRole: user['role'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}