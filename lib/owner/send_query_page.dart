import 'package:cattle_care_app/owner/owner_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendQueryPage extends StatefulWidget {
  final String fineId; // New parameter for fine ID

  const SendQueryPage({super.key, required this.fineId}); // Update constructor to accept fineId

  @override
  _SendQueryPageState createState() => _SendQueryPageState();
}

class _SendQueryPageState extends State<SendQueryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _queryIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _fineIdController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _fileComplaintIdController = TextEditingController(); // New Controller for File_Complaint_ID

  @override
  void initState() {
    super.initState();
    _generateQueryId();
    _fineIdController.text = widget.fineId; // Set the fine ID from the constructor
  }

  Future<void> _generateQueryId() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('query')
        .orderBy('query_id', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final lastDoc = querySnapshot.docs.first;
      final lastQueryId = lastDoc['query_id'] as String;
      final newIdNumber = int.parse(lastQueryId.split('_').last) + 1;
      _queryIdController.text = 'Q_${newIdNumber.toString().padLeft(3, '0')}';
    } else {
      _queryIdController.text = 'Q_001';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('query').doc(_queryIdController.text).set({
        'query_id': _queryIdController.text,
        'amount': _amountController.text,
        'cattle_id': _cattleIdController.text,
        'fine_id': _fineIdController.text,
        'owner_id': _ownerIdController.text,
        'owner_name': _ownerNameController.text,
        'query': _queryController.text,
        'reason': _reasonController.text,
        'file_complaint_id': _fileComplaintIdController.text, // Store File_Complaint_ID
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Query is sent successfully'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => OwnerHomePage(id: _ownerIdController.text),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchFineDetails() async {
    String fineId = _fineIdController.text.trim();

    if (!RegExp(r'^(F_\d{3,5})$').hasMatch(fineId)) {
      _showAlertDialog('Invalid Fine ID format. Please enter a valid Fine ID (e.g., F_001, F_0001).');
      return;
    }

    final fineSnapshot = await FirebaseFirestore.instance.collection('fine').doc(fineId).get();

    if (fineSnapshot.exists) {
      final fineData = fineSnapshot.data()!;
      _cattleIdController.text = fineData['cattle_id'] ?? '';
      _ownerIdController.text = fineData['owner_id'] ?? '';
      _ownerNameController.text = fineData['owner_name'] ?? '';
      _amountController.text = fineData['amount']?.toString() ?? '';
      _reasonController.text = fineData['reason'] ?? '';
      _fileComplaintIdController.text = fineData['complaint_id'] ?? ''; // Fetch File_Complaint_ID
    } else {
      _showAlertDialog('Fine ID does not exist.');
    }
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Submit Query'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: _fineIdController,
                      decoration: const InputDecoration(labelText: 'Fine ID'),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter fine ID' : null,
                    ),
                    const SizedBox(height:10),
                    ElevatedButton(
                      onPressed: _searchFineDetails,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Search',style: TextStyle(color: Colors.black,),),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _queryIdController,
                      decoration: const InputDecoration(labelText: 'Query ID'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _cattleIdController,
                      decoration: const InputDecoration(labelText: 'Cattle ID'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _ownerIdController,
                      decoration: const InputDecoration(labelText: 'Owner ID'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(labelText: 'Owner Name'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(labelText: 'Reason'),
                      readOnly: true,
                    ),
                    TextFormField(
                      controller: _fileComplaintIdController,
                      decoration: const InputDecoration(labelText: 'File Complaint ID'), // Read-Only Field for File_Complaint_ID
                      readOnly: true,
                    ),
                    TextFormField(
  controller: _queryController,
  decoration: const InputDecoration(labelText: 'Query'),
  validator: (value) {
    if (value!.isEmpty) {
    return 'Please enter a query';
  } else if (RegExp(r'^\d+$').hasMatch(value!)) {
    return 'Query cannot consist of only digits';
  } else if (!RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9\s.,?()\/\-]*$').hasMatch(value)) {
    return 'Query must contain at least one letter and can include digits or special characters like .,?()/-';
  }
  return null; // valid input
  },
),

                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Send Query'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
