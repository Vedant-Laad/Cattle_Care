import 'package:cattle_care_app/ngo/show_complaint_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShowComplaintsPage extends StatefulWidget {
  final String id;
  const ShowComplaintsPage({super.key,required this.id});

  @override
  _ShowComplaintsPageState createState() => _ShowComplaintsPageState();
}

class _ShowComplaintsPageState extends State<ShowComplaintsPage> {
  final _ownerIdController = TextEditingController();
  final _complaintIdController = TextEditingController();
  List<Map<String, dynamic>> _complaints = [];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _ownerIdController.text = widget.id; // Set the passed id to the NGO ID field
  }

  bool _isOwnerIdVerified = false; // New boolean flag to track verification status

  Future<void> _verifyOwnerId() async {
    String ownerId = _ownerIdController.text.trim();

    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an Owner ID')),
      );
      return;
    }

    try {
      // Fetch owner data
      DocumentSnapshot ownerDoc = await _firestore.collection('owner').doc(ownerId).get();

      if (!ownerDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID does not exist')),
        );
        return;
      }

      String ownerEmail = ownerDoc['Email'];
      String currentUserEmail = _auth.currentUser!.email!;

      // Verify email match
      if (ownerEmail != currentUserEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have permission to access this owner\'s complaints')),
        );
        return;
      }

      // Fetch complaints filtered by Owner ID
      QuerySnapshot complaintsSnapshot = await _firestore.collection('file_complaint')
          .where('ownerId', isEqualTo: ownerId)
          .get();

      setState(() {
        _complaints = complaintsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        _isOwnerIdVerified = true; // Set owner ID as verified
      });

    } catch (e) {
      print('Error verifying Owner ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying Owner ID: $e')),
      );
    }
  }

  Future<void> _viewSpecificComplaintDetails() async {
    String complaintId = _complaintIdController.text.trim();
    String ownerId = _ownerIdController.text.trim();

    if (complaintId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Complaint ID')),
      );
      return;
    }

    try {
      // Fetch the complaint document using the complaintId
      DocumentSnapshot complaintDoc = await _firestore.collection('file_complaint').doc(complaintId).get();

      if (!complaintDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint ID does not exist')),
        );
        return;
      }

      // Verify the ownerId in the complaint document matches the ownerId entered in the text field
      if (complaintDoc['ownerId'] != ownerId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID does not match the Complaint Owner ID')),
        );
        return;
      }

      // Navigate to the specific complaint details page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowComplaintDetailsPage(complaintId: complaintId),
        ),
      );

    } catch (e) {
      print('Error verifying Complaint ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying Complaint ID: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Complaints'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Allow the entire page to scroll
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _ownerIdController,
                decoration: const InputDecoration(labelText: 'Enter Owner ID'),
                readOnly: true, // Make the field read-only if verified
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isOwnerIdVerified ? null : _verifyOwnerId, // Disable button if owner ID is verified
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Get Details'),
              ),
              const SizedBox(height: 20),
              if (_complaints.isNotEmpty) ...[
                // Display complaints as individual cards in a responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600; // Define mobile view if screen is less than 600px
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _complaints.map((complaint) {
                        return Container(
                          width: isMobile ? double.infinity : constraints.maxWidth * 0.45, // Single card on mobile, two on larger screens
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.blue, width: 2), // Blue border for each card
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cattle ID: ${complaint['cattleId'] ?? ''}'),
                                  Text('Complaint ID: ${complaint['complaintId'] ?? ''}'),
                                  Text('Date of Complaint: ${complaint['dateOfComplaint'] ?? ''}'),
                                  Text('Location Description: ${complaint['locationDescription'] ?? ''}'),
                                  Text('Location Link: ${complaint['locationLink'] ?? ''}'),
                                  Text('Owner ID: ${complaint['ownerId'] ?? ''}'),
                                  Text('Owner Name: ${complaint['ownerName'] ?? ''}'),
                                  Text('Phone Number: ${complaint['ownerPhone'] ?? ''}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ] else if (_complaints.isEmpty && _ownerIdController.text.isNotEmpty) ...[
                const Text('No complaints found for this Owner ID.'),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _complaintIdController,
                decoration: const InputDecoration(labelText: 'Enter Complaint ID'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _viewSpecificComplaintDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('View Complaint Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
