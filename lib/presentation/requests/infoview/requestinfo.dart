import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestInfoView extends StatelessWidget {
  final Map<String, dynamic> requestData;
  final String requestId;
  final String currentUserId;
  final String currentUserRole;
  final firestore = FirebaseFirestore.instance;

  RequestInfoView({
    required this.requestData,
    required this.currentUserId,
    required this.currentUserRole,
    required this.requestId
  });

  void _approveRequest(BuildContext context) {

    // 1. Update the equipment 'assigned' field to the user id of the requester
    firestore.collection('equipment').doc(requestData['equipment_id']).update({
      'assigned': requestData['user_id']
    });

    // 2. Update the current request status to Approved
    firestore.collection('requests').doc(requestId).update({
      'request_status': 'Approved'
    });

    // 3. Set other requests for the same equipment to Declined
    firestore.collection('requests').where('equipment_id', isEqualTo: requestData['equipment_id']).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        final otherRequestData = doc.data() as Map<String, dynamic>;
        if (otherRequestData['user_id'] != requestData['user_id']) {
          doc.reference.update({'request_status': 'Declined'});
        }
      }
    });

    // Optional: Show a snackbar or a message indicating that the request has been approved
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request Approved')));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('requests')
          .where('equipment_id', isEqualTo: requestData['equipment_id'])
          .where('user_id', isEqualTo: requestData['user_id'])
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          DocumentSnapshot singleDoc = snapshot.data!.docs.first;
          Map<String, dynamic> updatedRequestData = singleDoc.data() as Map<String, dynamic>;

          return Scaffold(
            appBar: AppBar(
              title: Text(updatedRequestData?['name'] ?? 'N/A'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Request Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${updatedRequestData?['user_id'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                          Divider(),  // Dividers between items for clarity
                          Text('Name: ${updatedRequestData?['name'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                          Divider(),
                          Text('Purpose: ${updatedRequestData?['purpose'] ?? 'N/A'}', style: TextStyle(fontSize: 18)),
                          Divider(),
                          Text('Request Status: ${updatedRequestData?['request_status'] ?? 'N/A'}', style: TextStyle(fontSize: 18, color: updatedRequestData['request_status'] == 'Pending' ? Colors.orange : Colors.green)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (currentUserRole == 'Admin' && updatedRequestData['request_status'] == 'Pending')
                    ElevatedButton(
                      onPressed: () => _approveRequest(context),
                      child: Text('Approve Request'),
                    ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No matching request found.'));
        }
      },
    );
  }
}