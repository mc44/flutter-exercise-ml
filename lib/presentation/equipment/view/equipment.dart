import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../info_view/info.dart';

class EquipmentList extends StatelessWidget {
  final String userId;
  final String userName;
  final String userRole;

  EquipmentList({
    required this.userId,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Equipment List")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Logged in as $userName", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            buildEquipmentList("Requestable Equipment",
                FirebaseFirestore.instance.collection('equipment').where('assigned', isEqualTo: '').snapshots()),
            Divider(thickness: 2),
            buildEquipmentList("Assigned Equipment",
                FirebaseFirestore.instance.collection('equipment').where('assigned', isNotEqualTo: '').snapshots()),
          ],
        ),
      ),
    );
  }

  Widget buildEquipmentList(String title, Stream<QuerySnapshot> stream) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Center(child: Text('Something went wrong'));
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return Center(child: Text("No equipment found"));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Divider(),
            ...snapshot.data!.docs.map((doc) {
              final equipment = doc.data() as Map<String, dynamic>;
              final description = equipment['description'];
              final displayDescription = description.length > 30 ? description.substring(0, 30) : description;

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Image.network(equipment['picture'], width: 50),
                  title: Text(equipment['code']),
                  subtitle: Text(displayDescription),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EquipmentInfo(
                          equipmentData: equipment,
                          equipmentId: doc.id,
                          currentUserId: userId,
                          currentUserRole: userRole,
                          currentUserName: userName,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}