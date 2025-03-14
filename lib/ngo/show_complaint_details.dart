import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html; // Import for web downloads

class ShowComplaintDetailsPage extends StatefulWidget {
  final String complaintId; // Complaint ID passed from show_complaints_page.dart

  const ShowComplaintDetailsPage({super.key, required this.complaintId});

  @override
  _ShowComplaintDetailsPageState createState() => _ShowComplaintDetailsPageState();
}

class _ShowComplaintDetailsPageState extends State<ShowComplaintDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _complaintDetails;

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails(); // Fetch details on init
  }

  Future<void> _fetchComplaintDetails() async {
    try {
      DocumentSnapshot complaintSnapshot = await _firestore
          .collection('file_complaint')
          .doc(widget.complaintId)
          .get();
      if (complaintSnapshot.exists) {
        setState(() {
          _complaintDetails = complaintSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('No complaint found for ID: ${widget.complaintId}');
      }
    } catch (e) {
      print('Error fetching complaint details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaint details: $e')),
      );
    }
  }

  Future<void> _downloadImage(String url, String imageName) async {
    if (url.isNotEmpty) {
      try {
        // For web: Use the download URL to directly trigger a download in the browser
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", imageName) // Force download with provided name
          ..click();
      } catch (e) {
        print("Error downloading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error downloading image!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image URL available!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: _complaintDetails != null
              ? Card(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...buildTextFields(), // Add text fields
                        const SizedBox(height: 20),
                        // Fetch and display images
                        if (_complaintDetails!['imageUrl1'] != null) ...[
                          const Text('Image 1:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Image.network(_complaintDetails!['imageUrl1']),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _downloadImage(_complaintDetails!['imageUrl1'], 'image1.png');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Download Image 1'),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (_complaintDetails!['imageUrl2'] != null) ...[
                          const Text('Image 2:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Image.network(_complaintDetails!['imageUrl2'], height: 200, fit: BoxFit.cover),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _downloadImage(_complaintDetails!['imageUrl2'], 'image2.png');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Download Image 2'),
                          ),
                          const SizedBox(height: 20),
                        ],
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Navigate back to the previous page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Back to Complaints'),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()), // Show loading indicator while fetching data
        ),
      ),
    );
  }

  // Function to build read-only text fields for displaying complaint details
  List<Widget> buildTextFields() {
    return [
      TextField(
        controller: TextEditingController(text: _complaintDetails!['complaintId']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Complaint ID'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['cattleId']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Cattle ID'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['dateOfComplaint']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Date Of Complaint'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['locationDescription']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Location Description'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['locationLink']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Location Link'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['ownerId']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Owner ID'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['ownerName']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Owner Name'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['ownerPhone']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Phone Number'),
      ),
      TextField(
        controller: TextEditingController(text: _complaintDetails!['taluka']),
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Taluka'),
      ),
    ];
  }
}
