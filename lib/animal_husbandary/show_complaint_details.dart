import 'dart:html' as html; // Import for downloading functionality
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShowComplaintDetailsPage extends StatefulWidget {
  final String complaintId;

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
    _fetchComplaintDetails();
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

  Future<void> _downloadImage(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      try {
        // Create a link element to trigger the download with a forced .jpg extension
        final anchor = html.AnchorElement(href: imageUrl)
          ..setAttribute("download", "downloaded_image.jpg") // Force download as .jpg
          ..click();
      } catch (e) {
        print("Error downloading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error downloading image!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image uploaded yet!')),
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
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...buildTextFields(),
                        const SizedBox(height: 20),
                        // Display Image 1
                        if (_complaintDetails!['imageUrl1'] != null) ...[
                          const Text('Image 1:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Image.network(
                            '${_complaintDetails!['imageUrl1']}',
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator();
                            },
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          ),
                          ElevatedButton(
                            onPressed: () => _downloadImage(_complaintDetails!['imageUrl1']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Download Image 1'),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Display Image 2
                        if (_complaintDetails!['imageUrl2'] != null) ...[
                          const Text('Image 2:', style: TextStyle(fontWeight: FontWeight.bold)),
                          CachedNetworkImage(
                            imageUrl: _complaintDetails!['imageUrl2'],
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          ElevatedButton(
                            onPressed: () => _downloadImage(_complaintDetails!['imageUrl2']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text('Download Image 2'),
                          ),
                          const SizedBox(height: 20),
                        ],
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  List<Widget> buildTextFields() {
    return [
      _buildTextField('Complaint ID', 'complaintId'),
      _buildTextField('Cattle ID', 'cattleId'),
      _buildTextField('Date Of Complaint', 'dateOfComplaint'),
      _buildTextField('Location Description', 'locationDescription'),
      _buildTextField('Location Link', 'locationLink'),
      _buildTextField('Owner ID', 'ownerId'),
      _buildTextField('Owner Name', 'ownerName'),
      _buildTextField('Phone Number', 'ownerPhone'),
      _buildTextField('Taluka', 'taluka'),
    ];
  }

  Widget _buildTextField(String label, String fieldKey) {
    return _complaintDetails![fieldKey] != null
        ? TextField(
            controller: TextEditingController(text: _complaintDetails![fieldKey]),
            readOnly: true,
            decoration: InputDecoration(labelText: label),
          )
        : Container();
  }
}
