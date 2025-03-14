import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'animal_husbandary_homepage.dart';
import 'package:intl/intl.dart'; // To format the date

class IssueFinePage extends StatefulWidget {
  final String complaintId;
  final String id;

  const IssueFinePage({super.key, required this.complaintId,required this.id});

  @override
  _IssueFinePageState createState() => _IssueFinePageState();
}

class _IssueFinePageState extends State<IssueFinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fineIdController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _complaintIdController = TextEditingController();
  final TextEditingController _talukaController = TextEditingController(); // Taluka controller
  final TextEditingController _statusController = TextEditingController(); // Status controller
  final TextEditingController _dateController = TextEditingController(); // Date controller
  late String _fineId;

  @override
  void initState() {
    super.initState();
    _generateFineId();
    _fetchComplaintDetails();
    _statusController.text = 'Unpaid'; // Default value for status
    _setCurrentDate(); // Set the current date
  }

  void _generateFineId() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('fine')
        .orderBy('fine_id', descending: true)
        .limit(1)
        .get();
    String nextId = 'F_001';

    if (querySnapshot.docs.isNotEmpty) {
      final lastDocument = querySnapshot.docs.first;
      final lastFineId = lastDocument['fine_id'] as String;
      final lastIdNumber = int.parse(lastFineId.split('_')[1]);
      final nextIdNumber = lastIdNumber + 1;
      nextId = 'F_${nextIdNumber.toString().padLeft(3, '0')}';
    }

    setState(() {
      _fineId = nextId;
      _fineIdController.text = _fineId;
    });
  }

  void _fetchComplaintDetails() async {
    DocumentSnapshot complaintDoc = await FirebaseFirestore.instance
        .collection('file_complaint')
        .doc(widget.complaintId)
        .get();

    if (complaintDoc.exists) {
      _cattleIdController.text = complaintDoc['cattleId'] ?? 'N/A';
      _ownerIdController.text = complaintDoc['ownerId'] ?? 'N/A';
      _ownerNameController.text = complaintDoc['ownerName'] ?? 'N/A';
      _phoneNumberController.text = complaintDoc['ownerPhone'] ?? 'N/A';
      _complaintIdController.text = widget.complaintId;
      _talukaController.text = complaintDoc['taluka'] ?? 'N/A'; // Fetch Taluka

      DocumentSnapshot cattleDoc = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_cattleIdController.text)
          .get();

      if (cattleDoc.exists) {
        _breedController.text = cattleDoc['Breed'] ?? 'N/A';
        _colorController.text = cattleDoc['Color'] ?? 'N/A';
      } else {
        _showErrorDialog('Cattle not found');
      }
    } else {
      _showErrorDialog('Complaint not found.');
    }
  }

  void _setCurrentDate() {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dateController.text = formattedDate; // Set the current date
  }

  void _issueFine() async {
    if (_formKey.currentState!.validate()) {
      final fineData = {
        'cattle_id': _cattleIdController.text,
        'fine_id': _fineId,
        'owner_id': _ownerIdController.text,
        'owner_name': _ownerNameController.text,
        'phone_number': _phoneNumberController.text,
        'reason': _reasonController.text,
        'amount': _amountController.text,
        'breed': _breedController.text,
        'color': _colorController.text,
        'complaint_id': widget.complaintId,
        'taluka': _talukaController.text, // Add Taluka
        'status': _statusController.text, // Add status
        'date': _dateController.text, // Add date
      };

      await FirebaseFirestore.instance
          .collection('fine')
          .doc(_fineId)
          .set(fineData);

      // Increment Number_of_Fines_Issued in cattle collection
      DocumentSnapshot cattleDoc = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(_cattleIdController.text)
          .get();

      if (cattleDoc.exists) {
        int finesIssued = cattleDoc['Number_of_Fines_Issued'] ?? 0;
        finesIssued++;

        // Update the cattle document with the new number of fines
        await FirebaseFirestore.instance
            .collection('cattle')
            .doc(_cattleIdController.text)
            .update({'Number_of_Fines_Issued': finesIssued});
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Fine Issued'),
            content: Text('Fine issued successfully with ID: $_fineId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => AnimalHusbandaryHomePage(id: widget.id)),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      _formKey.currentState!.reset();
      _cattleIdController.clear();
      _ownerIdController.clear();
      _ownerNameController.clear();
      _phoneNumberController.clear();
      _reasonController.clear();
      _amountController.clear();
      _statusController.clear(); // Clear status
      _dateController.clear(); // Clear date
      _talukaController.clear(); // Clear Taluka
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

  String? _validateAmount(String? value) {
  // Define a regex pattern to match valid amount formats
  final RegExp regex = RegExp(
    r'^(Rs\.?\s*|)?(\d{1,3}(,\d{3})*|\d+)(\.\d{1,2})?/-?$',
  );

  if (value == null || value.isEmpty || !regex.hasMatch(value)) {
    return 'Please enter a valid amount (e.g., Rs. 5,500/- or 5500)';
  }
  return null;
}

  String? _validateReason(String? value) {
  // Define a regex pattern to match valid reason formats
  final RegExp regex = RegExp(
    r'^(?=.*[a-zA-Z]).+$',  // At least one letter must be present
  );

  if (value == null || value.isEmpty || !regex.hasMatch(value)) {
    return 'Please enter a valid reason (must contain letters and can include digits or special symbols)';
  }
  return null;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Fine'),
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
                  'Issue Fine',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fineIdController,
                        decoration: const InputDecoration(
                          labelText: 'Fine ID',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _complaintIdController,
                        decoration: const InputDecoration(
                          labelText: 'Complaint ID',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cattleIdController,
                        decoration: const InputDecoration(
                          labelText: 'Cattle ID',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _ownerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Owner Name',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _talukaController, // Taluka field
                        decoration: const InputDecoration(
                          labelText: 'Taluka',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason for Fine',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateReason,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateAmount,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _issueFine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Issue Fine'),
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
