import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'owner_home_page.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';  // Import this for formatting date

class RegisterCattlePage extends StatefulWidget {
  final String id;
  const RegisterCattlePage({super.key,required this.id});

  @override
  _RegisterCattlePageState createState() => _RegisterCattlePageState();
}

class _RegisterCattlePageState extends State<RegisterCattlePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController();

  String _cattleId = ''; // Initialize with an empty string
  final int _numberOfFinesIssued = 0;
  bool _isQrCodeGenerated = false;
  GlobalKey qrKey = GlobalKey();

  late String _currentDate;
  bool _isOwnerVerified = false; // Track if the owner is verified

  @override
  void initState() {
    super.initState();
    _ownerIdController.text=widget.id;
    _generateCattleId();
    _currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _colorController.dispose();
    _breedController.dispose();
    _medicalHistoryController.dispose();
    _ownerIdController.dispose();
    _talukaController.dispose();
    super.dispose();
  }

  Future<void> _generateCattleId() async {
    CollectionReference cattle = FirebaseFirestore.instance.collection('cattle');
    QuerySnapshot querySnapshot = await cattle.orderBy('Cattle_id', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String lastCattleId = querySnapshot.docs.first.get('Cattle_id');
      int nextId = int.parse(lastCattleId.substring(2)) + 1;
      setState(() {
        _cattleId = 'C${nextId.toString().padLeft(3, '0')}';
      });
    } else {
      setState(() {
        _cattleId = 'C001';
      });
    }
  }

  void _registerCattle() async {
    if (_formKey.currentState!.validate() && _isQrCodeGenerated && _isOwnerVerified) {
      final color = _colorController.text;
      final breed = _breedController.text;
      final medicalHistory = _medicalHistoryController.text;
      final ownerId = _ownerIdController.text;

      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      DocumentSnapshot ownerDoc = await FirebaseFirestore.instance.collection('owner').doc(ownerId).get();
      if (!ownerDoc.exists || ownerDoc['Email'] != currentUserEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Owner ID or email does not match.')),
        );
        return;
      }

      try {
        String qrCodeUrl = await _saveQrCodeToFirebase();

        await FirebaseFirestore.instance.collection('cattle').doc(_cattleId).set({
          'Cattle_id': _cattleId,
          'Breed': breed,
          'Color': color,
          'Medical History': medicalHistory,
          'Number_of_Fines_Issued': _numberOfFinesIssued,
          'Owner_id': ownerId,
          'QrCodeUrl': qrCodeUrl,
          'RegistrationDate': _currentDate,
          'Taluka': _talukaController.text, // Store Taluka
        });

        // In RegisterCattlePage
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: const Text('Registration Successful'),
      content: const Text('Thanks for registering your cattle.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => OwnerHomePage(id: widget.id), // Pass the cattle ID
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  },
);

      } catch (e) {
        print('Error adding cattle: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in proper data')),
      );
    }
  }

  Future<String> _saveQrCodeToFirebase() async {
    try {
      RenderRepaintBoundary boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      Reference ref = FirebaseStorage.instance.ref().child('QR/$_cattleId.png');
      UploadTask uploadTask = ref.putData(pngBytes);

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error saving QR code: $e');
      rethrow;
    }
  }

  void _generateQrCode() {
    setState(() {
      _isQrCodeGenerated = true;
    });
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


  String? _validateStringInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Only characters are allowed';
    }
    return null;
  }

  String? _validateOwnerId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Owner ID cannot be empty';
    }
    if (!RegExp(r'^O_\d{3}$').hasMatch(value)) {
      return 'Owner ID must be in the format O_001, O_002, etc.';
    }
    return null;
  }
Future<void> _verifyOwnerId() async {
    final ownerId = _ownerIdController.text;
    DocumentSnapshot ownerDoc = await FirebaseFirestore.instance.collection('owner').doc(ownerId).get();

    if (ownerDoc.exists) {
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
      if (ownerDoc['Email'] == currentUserEmail) {
        setState(() {
          _isOwnerVerified = true;
          _talukaController.text = ownerDoc.get('Taluka') ?? 'Not Available'; // Fetch and display Taluka
          _ownerIdController.text = ownerId; // Keep Owner ID read-only
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID verified successfully.')),
        );
      } else {
        setState(() {
          _isOwnerVerified = false;
          _talukaController.clear(); // Clear Taluka if not verified
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID not matched with email.')),
        );
      }
    } else {
      setState(() {
        _isOwnerVerified = false;
        _talukaController.clear(); // Clear Taluka if not verified
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner ID not found.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Cattle'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Register Cattle',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Display Cattle ID
                  Text(
                    'Cattle ID: $_cattleId',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _generateQrCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Generate QR Code'),
                  ),
                  const SizedBox(height: 10),
                  if (_isQrCodeGenerated)
                    RepaintBoundary(
                      key: qrKey,
                      child: QrImageView(
                        data: _cattleId,
                        size: 200,
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
  controller: _ownerIdController,
  decoration: const InputDecoration(labelText: 'Owner ID'),
  validator: _validateOwnerId,
  onChanged: (value) {
    setState(() {
      _isOwnerVerified = false; // Reset verification status on change
    });
  },
  readOnly: true, // Make the field read-only if verified
),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _verifyOwnerId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Verify Owner ID'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(labelText: 'Color'),
                    validator: _validateStringInput,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(labelText: 'Breed'),
                    validator: _validateStringInput,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _medicalHistoryController,
                    decoration: const InputDecoration(labelText: 'Medical History'),
                    validator:  _validateMedHistory,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _talukaController,
                    decoration: const InputDecoration(labelText: 'Taluka'),
                    enabled: false, // Make this field read-only
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerCattle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Register Cattle'),
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
