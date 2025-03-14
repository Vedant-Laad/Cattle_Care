import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FineIssued {
  final String fineId;
  final String ownerId;
  final String cattleId;
  final String fineAmount;
  final String reason;
  final String date;
  final String paymentStatus;
  final String phoneNumber;
  final String ownerName;

  FineIssued({
    required this.fineId,
    required this.ownerId,
    required this.cattleId,
    required this.fineAmount,
    required this.reason,
    required this.date,
    required this.paymentStatus,
    required this.phoneNumber,
    required this.ownerName,
  });

  factory FineIssued.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FineIssued(
      fineId: data['fine_id'] ?? '',
      ownerId: data['owner_id'] ?? '',
      cattleId: data['cattle_id'] ?? '',
      fineAmount: (data['amount'] ?? 0.0).toString(),
      reason: data['reason'] ?? '',
      date: data['date'] ?? '',
      paymentStatus: data['status'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      ownerName: data['owner_name'] ?? '',
    );
  }
}

class UpdatePaymentStatusPage extends StatefulWidget {
  final String fineId;

  const UpdatePaymentStatusPage({super.key, required this.fineId});

  @override
  _UpdatePaymentStatusPageState createState() => _UpdatePaymentStatusPageState();
}

class _UpdatePaymentStatusPageState extends State<UpdatePaymentStatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FineIssued? fineIssued;
  String selectedStatus = 'Unpaid'; // Default value for dropdown

  @override
  void initState() {
    super.initState();
    _fetchFineDetails(); // Fetch fine details based on fineId
  }

  Future<void> _fetchFineDetails() async {
    try {
      final doc = await _firestore.collection('fine').doc(widget.fineId).get();
      if (doc.exists) {
        setState(() {
          fineIssued = FineIssued.fromFirestore(doc);
          selectedStatus = fineIssued!.paymentStatus; // Set initial status from Firestore
        });
      }
    } catch (e) {
      print('Error fetching fine details: $e');
    }
  }

  Future<void> _updatePaymentStatus(String status) async {
    try {
      await _firestore.collection('fine').doc(widget.fineId).update({
        'status': status,
      });
      Navigator.pop(context, true); // Pass true to indicate success
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Payment Status'),
        backgroundColor: Colors.blue,
      ),
      body: fineIssued == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Add scrolling option
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
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
                        TextField(
                          controller: TextEditingController(text: fineIssued!.fineId),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Fine ID'),
                        ),
                        TextField(
                          controller: TextEditingController(text: fineIssued!.ownerId),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Owner ID'),
                        ),
                        TextField(
                          controller: TextEditingController(text: fineIssued!.cattleId),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Cattle ID'),
                        ),
                        TextField(
                          controller: TextEditingController(text: fineIssued!.ownerName),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Owner Name'),
                        ),
                        TextField(
                          controller: TextEditingController(text: fineIssued!.date),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Date'),
                        ),
                        TextField(
                          controller: TextEditingController(text: fineIssued!.fineAmount),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Amount'),
                        ),
                        TextField(
                          controller: TextEditingController(text: fineIssued!.reason),
                          readOnly: true,
                          decoration: const InputDecoration(labelText: 'Reason'),
                        ),
                        // Dropdown for payment status
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const [
                            DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'Unpaid', child: Text('Unpaid')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStatus = value; // Update the selected status
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedStatus.isNotEmpty) {
                              _updatePaymentStatus(selectedStatus); // Update payment status
                            } else {
                              // Optionally, show an error message if the status is empty
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a valid status.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Submit'),
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
