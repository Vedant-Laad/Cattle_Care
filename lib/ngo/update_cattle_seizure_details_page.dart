import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCattleSeizureDetailsPage extends StatefulWidget {
  final String seizureId; // The ID of the seizure to be updated

  const UpdateCattleSeizureDetailsPage({super.key, required this.seizureId});

  @override
  _UpdateCattleSeizureDetailsPageState createState() => _UpdateCattleSeizureDetailsPageState();
}

class _UpdateCattleSeizureDetailsPageState extends State<UpdateCattleSeizureDetailsPage> {
  String address = ''; // Initialize fields to empty strings
  String allowanceToSeizure = '';
  String allowanceToSell = '';
  String cattleId = '';
  String ownerId = '';
  String phone = '';
  String? statusOfSeizure; // To hold selected status
  String seizureDate = '';

  @override
  void initState() {
    super.initState();
    fetchSeizureDetails(); // Fetch seizure details on initialization
  }

  Future<void> fetchSeizureDetails() async {
    try {
      // Fetch seizure details using the seizure ID
      DocumentSnapshot seizureDoc = await FirebaseFirestore.instance
          .collection('seizure')
          .doc(widget.seizureId)
          .get();

      if (seizureDoc.exists) {
        setState(() {
          address = seizureDoc['address'];
          allowanceToSeizure = seizureDoc['allowance_to_seizure'];
          allowanceToSell = seizureDoc['allowance_to_sell'];
          cattleId = seizureDoc['cattle_id'];
          ownerId = seizureDoc['owner_id'];
          phone = seizureDoc['phone'];
          statusOfSeizure = seizureDoc['status_of_seizure']; // Updated to get the new status
          seizureDate = DateTime.now().toLocal().toString().split(' ')[0]; // Keep existing seizure date for reference
        });
      }
    } catch (e) {
      print('Error fetching seizure details: $e');
    }
  }

  Future<void> updateStatusOfSeizure() async {
    if (statusOfSeizure == null) {
      // Ensure status is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status.')),
      );
      return;
    }

    // Set the seizure date to the current date
    String currentDate = DateTime.now().toIso8601String(); // Get current date in ISO format

    // Only update if the status has changed
    try {
      await FirebaseFirestore.instance
          .collection('seizure')
          .doc(widget.seizureId)
          .update({
        'status_of_seizure': statusOfSeizure, // Update to the selected status
        'seizure_date': currentDate, // Store current date as seizure_date
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Data updated successfully!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pop(context); // Return to the previous page
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating status: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Cattle Seizure Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Read-only fields
                TextField(
                  controller: TextEditingController(text: address),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: allowanceToSeizure),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Allowance to Seizure'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: allowanceToSell),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Allowance to Sell'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: cattleId),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Cattle ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: ownerId),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Owner ID'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: phone),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: seizureDate),
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Seizure Date'),
                ),
                const SizedBox(height: 20),

                // Dropdown for status of seizure
                const Text('Status of Seizure:', style: TextStyle(fontSize: 16)),
                DropdownButton<String>(
                  value: statusOfSeizure,
                  items: <String>['Seized', 'Not Seized'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      statusOfSeizure = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: updateStatusOfSeizure, // Call function to update status
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Update Status'), // Button text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
