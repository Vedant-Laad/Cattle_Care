import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'file_complaint_page.dart';
import 'package:cattle_care_app/user/qr_scanner.dart';  // Import the QR Scanner page
//import 'qr_scanner_page.dart';  // Import the scanner functionality

class OwnerDetailsPage extends StatefulWidget {
  final String id;
  const OwnerDetailsPage({super.key,required this.id});

  @override
  _OwnerDetailsPageState createState() => _OwnerDetailsPageState();
}

class _OwnerDetailsPageState extends State<OwnerDetailsPage> {
  final _searchController = TextEditingController();
  final _cattleIdController = TextEditingController();
  final _ownerIdController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _searchCattle() async {
    final cattleId = _searchController.text.trim();
    if (cattleId.isEmpty) {
      _showErrorDialog('Please enter a Cattle ID');
      return;
    }

    try {
      final cattleDoc = await _firestore.collection('cattle').doc(cattleId).get();
      if (cattleDoc.exists) {
        // Populate fields with cattle details
        _cattleIdController.text = cattleId;
        _ownerIdController.text = cattleDoc['Owner_id'] ?? 'N/A';

        final ownerId = cattleDoc['Owner_id'];
        final ownerDoc = await _firestore.collection('owner').doc(ownerId).get();
        if (ownerDoc.exists) {
          _ownerNameController.text = ownerDoc['Name'] ?? 'N/A';
          _addressController.text = ownerDoc['Address'] ?? 'N/A';
          _phoneNumberController.text = ownerDoc['Phone Number'] ?? 'N/A';
        }
      } else {
        _showErrorDialog('Cattle ID not found');
      }
    } catch (e) {
      _showErrorDialog('Error retrieving cattle details');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _fileComplaint(BuildContext context) {
    if (_cattleIdController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileComplaintPage(cattleId: _cattleIdController.text,id: widget.id,),
        ),
      );
    } else {
      _showErrorDialog('Cattle ID is required to file a complaint');
    }
  }

  // Function to launch the QR scanner and get the scanned result
  Future<void> _scanQRCode(BuildContext context) async {
    final scannedCattleId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScanner(),
      ),
    );

    if (scannedCattleId != null && scannedCattleId is String) {
      setState(() {
        _searchController.text = scannedCattleId;  // Set the scanned value to the search field
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Search Cattle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Cattle ID',
                    border: OutlineInputBorder(),
                    
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _scanQRCode(context),  // Button to scan QR code
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Scan QR Code'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _searchCattle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Search'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Owner Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _cattleIdController,
                  decoration: const InputDecoration(
                    labelText: 'Cattle ID',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ownerIdController,
                  decoration: const InputDecoration(
                    labelText: 'Owner ID',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _fileComplaint(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('File Complaint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
