import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../requests/infoview/requestinfo.dart';

class EquipmentInfo extends StatefulWidget {
  final Map<String, dynamic> equipmentData;
  final String equipmentId;
  final String currentUserId;
  final String currentUserRole;
  final String currentUserName;

  EquipmentInfo({required this.equipmentData, required this.currentUserId, required this.currentUserRole, required this.currentUserName, required this.equipmentId});

  @override
  _EquipmentInfoState createState() => _EquipmentInfoState();
}

class _EquipmentInfoState extends State<EquipmentInfo> {
  late FirebaseFirestore _firestore;
  late Stream<DocumentSnapshot> _equipmentStream;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _equipmentStream = _firestore.collection('equipment').doc(widget.equipmentId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.equipmentData['code']),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),  // Provide padding to the entire body
        children: [
        Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.network(
              widget.equipmentData['picture'],
              width: MediaQuery.of(context).size.width * 0.6,  // Make the image a bit smaller and centered
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 20),
          Text('Code: ${widget.equipmentData['code']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(height: 10),
          Text('Specs: ${widget.equipmentData['specs']}'),
          SizedBox(height: 10),
          Text('Description: ${widget.equipmentData['description']}'),
          SizedBox(height: 20),
              ],
          ),
          //Assigned To Section
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('equipment').doc(widget.equipmentId).snapshots(),
            builder: (context, equipmentSnapshot) {
              if (!equipmentSnapshot.hasData) {
                return CircularProgressIndicator();
              }

              if (equipmentSnapshot.hasError) {
                return Text('Error fetching equipment data.');
              }

              final updatedEquipmentData = equipmentSnapshot.data!.data() as Map<String, dynamic>;

              // Check if the equipment is assigned
              if (updatedEquipmentData['assigned'].isNotEmpty) {
                return StreamBuilder<DocumentSnapshot>(
                  stream: _firestore.collection('users').doc(updatedEquipmentData['assigned']).snapshots(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    if (userSnapshot.hasError) {
                      return Text('Error fetching assigned user data.');
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text('Assigned to: ${userData['name']}'),
                        subtitle: Text('Role: ${userData['role']}'),
                        onTap: () {
                          _showUserInfoPopup(context, userData);
                        },
                      ),
                    );
                  },
                );
              } else {
                return SizedBox.shrink(); // Return an empty widget if the equipment is not assigned
              }
            },
          ),

          // Then the request section:
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('requests')
                .where('user_id', isEqualTo: widget.currentUserId)
                .where('equipment_id', isEqualTo: widget.equipmentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              bool userHasMadeRequest = snapshot.data!.docs.isNotEmpty;
              var myRequests = snapshot.data!.docs.map((doc) => {
                'data': doc.data() as Map<String, dynamic>,
                'id': doc.id
              }).toList();

              return Column(
                children: [
                  if (!userHasMadeRequest && widget.equipmentData['assigned'].isEmpty && widget.currentUserRole == 'Employee')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
                      child: ElevatedButton(
                        child: Text('Request'),
                        onPressed: _showRequestPopup,
                      ),
                    ),

                  if (userHasMadeRequest) ...[
                    SizedBox(height: 20),
                    Text('My Request:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...myRequests.map((request) {
                      var requestData = request['data'];
                      return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                        title: Text((requestData as Map<String, dynamic>)?['name'] ?? 'N/A'),
                        subtitle: Text('Purpose: ${requestData['purpose']}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RequestInfoView(
                                requestData: requestData,
                                currentUserId: widget.currentUserId,
                                currentUserRole: widget.currentUserRole,
                                requestId: widget.equipmentId,
                              ),
                            ),
                          );
                        },
                        )
                      );
                    }).toList(),
                  ],
                ],
              );
            },
          ),

          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('requests')
                .where('equipment_id', isEqualTo: widget.equipmentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error fetching equipment requests.');
              }
              if (snapshot.data!.docs.isEmpty) {
                return Text('No existing requests for this equipment.');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.currentUserRole == 'Admin' ? 'Requests' : 'Other Requests:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...snapshot.data!.docs.where((doc) => doc['user_id'] != widget.currentUserId).map((doc) {
                    final requestData = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(requestData['name']),
                        subtitle: Text('Purpose: ${requestData['purpose']}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequestInfoView(
                                    requestData: requestData,
                                    currentUserId: widget.currentUserId,
                                    currentUserRole: widget.currentUserRole,
                                    requestId: doc.id,
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
          ),
        ],
      ),
    );
  }

  void _showUserInfoPopup(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Information'),
          content: SingleChildScrollView(  // Added SingleChildScrollView in case there's too much content
            child: ListBody(  // Changed to ListBody for a cleaner structure
              children: <Widget>[
                Text('Name: ${userData['name']}'),
                SizedBox(height: 12),
                Text('Role: ${userData['role']}'),
                SizedBox(height: 12),
                Text('Email: ${userData['email']}'),
                SizedBox(height: 12),
                Text('Number: ${userData['number']}'),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> hasUserMadeRequest() async {
    final request = await FirebaseFirestore.instance
        .collection('requests')
        .where('user_id', isEqualTo: widget.currentUserId)
        .where('equipment_id', isEqualTo: widget.equipmentData['id'])
        .get();

    return request.docs.isNotEmpty;
  }

  void _showRequestPopup() async {
    final _requestFormKey = GlobalKey<FormState>();
    String purpose = '';
    String requestStatus = 'Pending';  // Default status

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Equipment'),
          content: Form(
            key: _requestFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Purpose'),
                  onSaved: (value) => purpose = value!,
                  validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_requestFormKey.currentState!.validate()) {
                  _requestFormKey.currentState!.save();
                  // Save to Firebase 'requests' collection
                  FirebaseFirestore.instance.collection('requests').add({
                    'user_id': widget.currentUserId,
                    'name': widget.currentUserName,
                    'purpose': purpose,
                    'request_status': requestStatus,
                    'equipment_id': widget.equipmentId,
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Submit Request'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}


