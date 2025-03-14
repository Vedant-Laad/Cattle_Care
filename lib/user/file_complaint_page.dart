import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_images.dart'; // Import the photo upload page
import 'user_home_page.dart'; // Import your UserHomePage

class FileComplaintPage extends StatefulWidget {
  final String cattleId;
  final String id;
  const FileComplaintPage({super.key, required this.cattleId,required this.id});

  @override
  _FileComplaintPageState createState() => _FileComplaintPageState();
}

class _FileComplaintPageState extends State<FileComplaintPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _fileComplaintIdController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();
  final TextEditingController _locationDescriptionController = TextEditingController();
  final TextEditingController _dateOfComplaintController = TextEditingController();

  String? _selectedTaluka;
  final List<String> _talukas = [
    'Pernem', 'Bardez', 'Bicholim', 'Satari', 'Tiswadi', 'Ponda', 
    'Murmgao', 'Salcete', 'Sanguem', 'Quepem', 'Dharbandora', 'Canacona'
  ];

  String? _imageUrl1;
  String? _imageUrl2;

  @override
  void initState() {
    super.initState();
    _fetchCattleDetails(widget.cattleId);
    _generateComplaintId(); // Generate complaint ID on init
    _dateOfComplaintController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _fetchCattleDetails(String cattleId) async {
    try {
      final cattleDoc = await _firestore.collection('cattle').doc(cattleId).get();
      if (cattleDoc.exists) {
        _cattleIdController.text = cattleId;
        _ownerIdController.text = cattleDoc['Owner_id'];
        
        final ownerId = cattleDoc['Owner_id'];
        final ownerDoc = await _firestore.collection('owner').doc(ownerId).get();
        if (ownerDoc.exists) {
          _ownerNameController.text = ownerDoc['Name'] ?? 'N/A';
          _ownerPhoneController.text = ownerDoc['Phone Number'] ?? 'N/A';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching cattle details.')),
      );
    }
  }

  Future<void> _generateComplaintId() async {
    final complaintsCollection = await _firestore.collection('file_complaint').get();
    final complaintCount = complaintsCollection.docs.length + 1;
    _fileComplaintIdController.text = 'FC_${complaintCount.toString().padLeft(3, '0')}';
  }

  Future<void> _openGoogleMaps(BuildContext context) async {
    const googleMapsUrl = 'https://www.google.com/maps';
    final Uri uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      _showManualEntryDialog(); // Allow user to enter location manually
    }
  }

  void _showManualEntryDialog() {
    TextEditingController locationController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Location'),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(hintText: 'Enter location link'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit',style: TextStyle(color: Colors.black,),),
              onPressed: () {
                setState(() {
                  _locationLinkController.text = locationController.text; // Set location link
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

void _fileComplaint(BuildContext context) async {
  if (_locationLinkController.text.isEmpty ||
      _locationDescriptionController.text.isEmpty ||
      _selectedTaluka == null ||
      _imageUrl1 == null ||
      _imageUrl2 == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all required fields and upload photos.')),
    );
    return;
  }

  // Validate the location description
  final locationDescription = _locationDescriptionController.text;
  final RegExp locationDescriptionRegExp = RegExp(r'^[a-zA-Z]+[a-zA-Z0-9.,() -]*$');

  if (!locationDescriptionRegExp.hasMatch(locationDescription)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location Description must start with letters and can only contain letters, numbers, and special symbols like .,()-')),
    );
    return;
  }

  // Validate the location link
  final locationLink = _locationLinkController.text;
  final RegExp googleMapsLinkRegExp = RegExp(
    r'^(https:\/\/(www\.)?google\.com\/maps|https:\/\/maps\.app\.goo\.gl)',
  );

  if (!googleMapsLinkRegExp.hasMatch(locationLink)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a valid Google Maps URL.')),
    );
    return;
  }

  // If validation passes, continue with filing the complaint
  Map<String, dynamic> complaintData = {
    'complaintId': _fileComplaintIdController.text,
    'cattleId': _cattleIdController.text,
    'ownerId': _ownerIdController.text,
    'ownerName': _ownerNameController.text,
    'ownerPhone': _ownerPhoneController.text,
    'locationLink': _locationLinkController.text,
    'locationDescription': _locationDescriptionController.text,
    'taluka': _selectedTaluka,
    'dateOfComplaint': _dateOfComplaintController.text,
    'imageUrl1': _imageUrl1,
    'imageUrl2': _imageUrl2,
  };

  try {
    await _firestore.collection('file_complaint').doc(_fileComplaintIdController.text).set(complaintData);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Complaint filed successfully!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => UserHomePage(id: widget.id),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to file complaint: $e')),
    );
  }
}


  void _onImagesUploaded(String imageUrl1, String imageUrl2) {
    setState(() {
      _imageUrl1 = imageUrl1;
      _imageUrl2 = imageUrl2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Complaint'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _fileComplaintIdController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Complaint ID'),
                  ),
                  TextField(
                    controller: _cattleIdController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Cattle ID'),
                  ),
                  TextField(
                    controller: _ownerIdController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Owner ID'),
                  ),
                  TextField(
                    controller: _ownerNameController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Owner Name'),
                  ),
                  TextField(
                    controller: _ownerPhoneController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Owner Phone'),
                  ),
                  TextField(
                    controller: _locationLinkController,
                    decoration: const InputDecoration(labelText: 'Location Link'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _openGoogleMaps(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Open Google Maps'),
                  ),
                  TextField(
                    controller: _locationDescriptionController,
                    decoration: const InputDecoration(labelText: 'Location Description'),
                  ),
                  DropdownButtonFormField(
                    value: _selectedTaluka,
                    hint: const Text('Select Taluka'),
                    items: _talukas.map((taluka) {
                      return DropdownMenuItem(
                        value: taluka,
                        child: Text(taluka),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTaluka = value;
                      });
                    },
                  ),
                  TextField(
                    controller: _dateOfComplaintController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Date of Complaint'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PhotoUploadPage(
                            complaintId: _fileComplaintIdController.text,
                            onImagesUploaded: _onImagesUploaded,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Upload Photos'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _fileComplaint(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Submit Complaint'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
