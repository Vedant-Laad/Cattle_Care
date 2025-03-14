import 'package:cattle_care_app/ngo/show_complaint_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class ShowComplaintsPage extends StatefulWidget {
  final String id;
  const ShowComplaintsPage({super.key, required this.id});

  @override
  _ShowComplaintsPageState createState() => _ShowComplaintsPageState();
}

class _ShowComplaintsPageState extends State<ShowComplaintsPage> {
  final _ngoIdController = TextEditingController();
  final _complaintIdController = TextEditingController();
  String? _taluka;
  List<Map<String, dynamic>> _complaints = [];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    _ngoIdController.text = widget.id; // Set the passed id to the NGO ID field
  }
  Future<void> _verifyNgoId() async {
    String ngoId = _ngoIdController.text.trim();

    if (ngoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an NGO ID')),
      );
      return;
    }

    try {
      DocumentSnapshot ngoDoc = await _firestore.collection('ngo').doc(ngoId).get();

      if (!ngoDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO ID does not exist')),
        );
        return;
      }

      String ngoEmail = ngoDoc['Email'];
      String currentUserEmail = _auth.currentUser!.email!;

      if (ngoEmail != currentUserEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have permission to access this NGO\'s complaints')),
        );
        return;
      }

      setState(() {
        _taluka = ngoDoc['Taluka'];
        _ngoIdController.text = ngoId; // Set the NGO ID to the controller
        _ngoIdController.selection = TextSelection.fromPosition(TextPosition(offset: ngoId.length)); // Move the cursor to the end
        _ngoIdController.text = ngoId; // Set NGO ID to read-only
      });

      QuerySnapshot complaintsSnapshot = await _firestore.collection('file_complaint')
          .where('taluka', isEqualTo: _taluka)
          .get();

      setState(() {
        _complaints = complaintsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });

    } catch (e) {
      print('Error verifying NGO ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying NGO ID: $e')),
      );
    }
  }

  Future<void> _seeComplaintDetails() async {
    String complaintId = _complaintIdController.text.trim();

    if (complaintId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Complaint ID')),
      );
      return;
    }

    try {
      DocumentSnapshot complaintDoc = await _firestore.collection('file_complaint').doc(complaintId).get();

      if (!complaintDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint ID does not exist')),
        );
        return;
      }

      // Fetch the taluka of the complaint and compare it with NGO's taluka
      String complaintTaluka = complaintDoc['taluka'];

      if (complaintTaluka != _taluka) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You do not have permission to view this complaint')),
        );
        return;
      }

      // If the taluka matches, navigate to the complaint details page
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
      body: SingleChildScrollView( // Allows scrolling for the entire page
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _ngoIdController,
                decoration: const InputDecoration(labelText: 'Enter NGO ID'),
                readOnly: true, // Make the NGO ID field read-only after verification
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _verifyNgoId,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Get details'),
              ),
              const SizedBox(height: 20),
              if (_taluka != null) ...[
                Text(
                  'Taluka: $_taluka',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Display complaints as cards
                Wrap(
                  spacing: 10, // Space between cards
                  runSpacing: 10, // Space between rows
                  children: _complaints.map((complaint) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: kIsWeb ? MediaQuery.of(context).size.width / 2 - 15 : MediaQuery.of(context).size.width - 40, // Adjust width based on device
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
                            Text('Taluka: ${complaint['taluka'] ?? ''}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_complaints.isEmpty) const Text('No complaints found for this Taluka.'),
                const SizedBox(height: 20),
                TextField(
                  controller: _complaintIdController,
                  decoration: const InputDecoration(labelText: 'Enter Complaint ID'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _seeComplaintDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('See Complaint Details'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
