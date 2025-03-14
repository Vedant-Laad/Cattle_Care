import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cattle_care_app/animal_husbandary/issue_fines.dart'; // Import the IssueFinePage
import 'package:cattle_care_app/animal_husbandary/show_complaint_details.dart'; // Import the ShowComplaintDetailsPage

class ShowComplaintsPage extends StatefulWidget {
  final String id;
  const ShowComplaintsPage({super.key,required this.id});

  @override
  _ShowComplaintsPageState createState() => _ShowComplaintsPageState();
}

class _ShowComplaintsPageState extends State<ShowComplaintsPage> {
  final TextEditingController _fileComplaintIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _complaints = [];
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAllComplaints(); // Fetch all complaints when the page loads
  }

  Future<void> _fetchAllComplaints() async {
    try {
      QuerySnapshot complaintsSnapshot = await _firestore.collection('file_complaint').get();
      setState(() {
        _complaints = complaintsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    }
  }

  void _filterComplaintsByDate() {
    String date = _dateController.text.trim();

    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a date to filter')),
      );
      return;
    }

    setState(() {
      _complaints = _complaints.where((complaint) {
        return complaint['dateOfComplaint']?.contains(date) ?? false;
      }).toList();
    });
  }

  Future<void> _verifyComplaintAndProceed(Function(String) onSuccess) async {
    String fileComplaintId = _fileComplaintIdController.text.trim();
    if (fileComplaintId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a File Complaint ID')),
      );
      return;
    }

    try {
      // Check if the complaint exists in Firestore
      DocumentSnapshot complaintDoc = await _firestore.collection('file_complaint').doc(fileComplaintId).get();

      if (complaintDoc.exists) {
        // If complaint exists, proceed to the next action
        onSuccess(fileComplaintId);
      } else {
        // If complaint doesn't exist, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint ID not found')),
        );
      }
    } catch (e) {
      print('Error verifying complaint: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying complaint: $e')),
      );
    }
  }

  void _issueFine() {
    _verifyComplaintAndProceed((fileComplaintId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IssueFinePage(complaintId: fileComplaintId,id:widget.id),
        ),
      );
    });
  }

  void _showComplaintDetails() {
    _verifyComplaintAndProceed((fileComplaintId) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShowComplaintDetailsPage(complaintId: fileComplaintId.toUpperCase()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Complaints'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Enter Date (DD/MM/YYYY)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _filterComplaintsByDate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Filter by Date'),
            ),
            const SizedBox(height: 20),
            // Display complaints as cards
            _complaints.isNotEmpty 
                ? Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: _complaints.map((complaint) {
                      return Container(
                        width: MediaQuery.of(context).size.width > 600
                            ? MediaQuery.of(context).size.width / 2 - 30 // Half the width for laptops
                            : MediaQuery.of(context).size.width - 40, // Full width for mobiles
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cattle ID: ${complaint['cattleId'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Complaint ID: ${complaint['complaintId'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Date Of Complaint: ${complaint['dateOfComplaint'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Location Description: ${complaint['locationDescription'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Location Link: ${complaint['locationLink'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Owner ID: ${complaint['ownerId'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Owner Name: ${complaint['ownerName'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                              Text('Phone Number: ${complaint['ownerPhone'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const Text('No complaints found.'),
            const SizedBox(height: 20),
            TextField(
              controller: _fileComplaintIdController,
              decoration: const InputDecoration(labelText: 'Enter File Complaint ID'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _issueFine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Issue Fine'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showComplaintDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Show Complaint Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
