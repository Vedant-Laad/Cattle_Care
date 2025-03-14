import 'package:cattle_care_app/ngo/ngo_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:cattle_care_app/user/qr_scanner.dart'; // Import the QR Scanner page

class UpdateCattleDataPage extends StatefulWidget {
  final String id;
  const UpdateCattleDataPage({super.key,required this.id});

  @override
  _UpdateCattleDataPageState createState() => _UpdateCattleDataPageState();
}

class _UpdateCattleDataPageState extends State<UpdateCattleDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();

  void _searchCattle() async {
    final cattleId = _searchController.text.trim();

    // Fetch data from Firestore
    final cattleSnapshot = await FirebaseFirestore.instance
        .collection('cattle')
        .doc(cattleId)
        .get();

    if (cattleSnapshot.exists) {
      final data = cattleSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _cattleIdController.text = cattleId;
        _colorController.text = data['Color'] ?? '';
        _breedController.text = data['Breed'] ?? '';
        _medicalHistoryController.text = data['Medical History'] ?? '';
        _ownerIdController.text = data['Owner_id'] ?? '';
      });
    } else {
      _showErrorDialog('Cattle ID not found');
    }
  }

  String? _validateMedHistory(String? value) {
    // Check if the value is empty
    if (value == null || value.isEmpty) {
      return 'Medical history cannot be empty';
    }

    // Regular expression for validating medical history
    // At least one letter is required, and can include digits and special characters
    if (!RegExp(r'^(?=.*[a-zA-Z])[\w\s.,?()/-]*$').hasMatch(value)) {
      return 'Medical history must contain at least one character and can include digits and symbols like . ? - ( ) /';
    }

    return null; // Return null if valid
  }

  Future<void> _scanQRCode() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScanner()),
    );

    if (scannedCode != null) {
      setState(() {
        _searchController.text = scannedCode;
      });
      _searchCattle(); // Automatically search after scanning the QR code
    }
  }

  void _updateMedicalHistory() async {
    if (_formKey.currentState!.validate()) {
      final updatedMedicalHistory = _medicalHistoryController.text;
      final cattleId = _cattleIdController.text;

      // Update Firestore document with new medical history
      await FirebaseFirestore.instance.collection('cattle').doc(cattleId).update({
        'Medical History': updatedMedicalHistory,
      });

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Successful'),
            content: Text('Medical history updated to: $updatedMedicalHistory'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => NGOHomePage(id: widget.id),
                  ),
                ); // Navigate to NGO homepage
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Cattle Data'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Cattle Data',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search with Cattle ID',
                          border: OutlineInputBorder(),
                          
                        ),
                        readOnly:true,
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _scanQRCode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _cattleIdController,
                        decoration: const InputDecoration(
                          labelText: 'Cattle ID',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () {
                          // Optionally inform the user that this field is read-only
                          _showErrorDialog('Cattle ID cannot be modified');
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: 'Breed',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _medicalHistoryController,
                        decoration: const InputDecoration(
                          labelText: 'Medical History',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: _validateMedHistory,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _ownerIdController,
                        decoration: const InputDecoration(
                          labelText: 'Owner ID',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateMedicalHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
