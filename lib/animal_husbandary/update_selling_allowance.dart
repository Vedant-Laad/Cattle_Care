import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateSellingAllowancePage extends StatefulWidget {
  final String seizureId;

  const UpdateSellingAllowancePage({super.key, required this.seizureId});

  @override
  _UpdateSellingAllowancePageState createState() =>
      _UpdateSellingAllowancePageState();
}

class _UpdateSellingAllowancePageState
    extends State<UpdateSellingAllowancePage> {
  // Controllers to display seizure details
  final TextEditingController addressController = TextEditingController();
  final TextEditingController allowanceToSeizureController =
      TextEditingController();
  final TextEditingController cattleIdController = TextEditingController();
  final TextEditingController dateOfSeizureController =
      TextEditingController();
  final TextEditingController ownerIdController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController statusOfSeizureController =
      TextEditingController();
  final TextEditingController talukaController = TextEditingController();

  String? allowanceToSell; // Dropdown for updating allowance_to_sell
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeizureDetails();
  }

  Future<void> fetchSeizureDetails() async {
    try {
      // Fetch seizure details by seizure_id from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('seizure')
          .doc(widget.seizureId)
          .get();

      if (doc.exists) {
        // Populate the controllers with data
        setState(() {
          addressController.text = doc['address'] ?? '';
          allowanceToSeizureController.text = doc['allowance_to_seizure'] ?? '';
          allowanceToSell = doc['allowance_to_sell'] ?? 'No';
          cattleIdController.text = doc['cattle_id'] ?? '';
          dateOfSeizureController.text = doc['date_of_seizure_allowance'] ?? '';
          ownerIdController.text = doc['owner_id'] ?? '';
          phoneController.text = doc['phone'] ?? '';
          statusOfSeizureController.text = doc['status_of_seizure'] ?? '';
          talukaController.text = doc['taluka'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching seizure details: $e');
    }
  }

  Future<void> updateSellingStatus() async {
    try {
      // Update the allowance_to_sell field in the Firestore document
      await FirebaseFirestore.instance
          .collection('seizure')
          .doc(widget.seizureId)
          .update({'allowance_to_sell': allowanceToSell});

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Selling Status updated successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context, true); // Go back to the previous page
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating selling status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Selling Allowance'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Seizure ID (read-only)
                        TextField(
                          controller: TextEditingController(text: widget.seizureId),
                          decoration: const InputDecoration(labelText: 'Seizure ID'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Address (read-only)
                        TextField(
                          controller: addressController,
                          decoration: const InputDecoration(labelText: 'Address'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Allowance to Seizure (read-only)
                        TextField(
                          controller: allowanceToSeizureController,
                          decoration:
                              const InputDecoration(labelText: 'Allowance to Seizure'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Cattle ID (read-only)
                        TextField(
                          controller: cattleIdController,
                          decoration: const InputDecoration(labelText: 'Cattle ID'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Date of Seizure Allowance (read-only)
                        TextField(
                          controller: dateOfSeizureController,
                          decoration: const InputDecoration(labelText: 'Date of Seizure Allowance'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Owner ID (read-only)
                        TextField(
                          controller: ownerIdController,
                          decoration: const InputDecoration(labelText: 'Owner ID'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Phone (read-only)
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Status of Seizure (read-only)
                        TextField(
                          controller: statusOfSeizureController,
                          decoration:
                              const InputDecoration(labelText: 'Status of Seizure'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Taluka (read-only)
                        TextField(
                          controller: talukaController,
                          decoration: const InputDecoration(labelText: 'Taluka'),
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        // Allowance to Sell (Dropdown to update)
                        DropdownButtonFormField<String>(
                          value: allowanceToSell,
                          decoration: const InputDecoration(labelText: 'Allowance to Sell'),
                          items: const [
                            DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                            DropdownMenuItem(value: 'No', child: Text('No')),
                          ],
                          onChanged: (newValue) {
                            setState(() {
                              allowanceToSell = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Update Button
                        ElevatedButton(
                          onPressed: updateSellingStatus,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.black,
                          ),
                          child: const Text('Update Selling Status'),
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
