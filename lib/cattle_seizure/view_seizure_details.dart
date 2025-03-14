import 'package:cattle_care_app/animal_husbandary/update_selling_allowance.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSeizureDetailsPage extends StatefulWidget {
  const ViewSeizureDetailsPage({super.key});

  @override
  _ViewSeizureDetailsPageState createState() => _ViewSeizureDetailsPageState();
}

class _ViewSeizureDetailsPageState extends State<ViewSeizureDetailsPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController seizureIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Seizure Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
              onChanged: (value) {
                setState(() {}); // Rebuild when date changes
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: seizureIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Seizure ID to update allowance',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                navigateToUpdateSellingAllowance(seizureIdController.text);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Update Selling Allowance',
                style: TextStyle(color: Colors.black, backgroundColor: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('seizure').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading seizure details.'));
                }

                final seizureDetails = snapshot.data!.docs.where((seizure) {
                  final date = seizure['date_of_seizure_allowance'] as String?;
                  return dateController.text.isEmpty || date == dateController.text;
                }).toList();

                return Column(
                  children: seizureDetails.map((seizure) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.blue), // Border color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Address: ${seizure['address'] ?? ''}'),
                            Text('Allowance to Seizure: ${seizure['allowance_to_seizure'] ?? ''}'),
                            Text('Allowance to Sell: ${seizure['allowance_to_sell'] ?? ''}'),
                            Text('Cattle ID: ${seizure['cattle_id'] ?? ''}'),
                            Text('Date of Seizure: ${seizure['date_of_seizure_allowance'] ?? ''}'),
                            Text('Owner ID: ${seizure['owner_id'] ?? ''}'),
                            Text('Phone: ${seizure['phone'] ?? ''}'),
                            Text('Seizure ID: ${seizure['seizure_id'] ?? ''}'),
                            Text('Status of Seizure: ${seizure['status_of_seizure'] ?? ''}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Return to Home',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> navigateToUpdateSellingAllowance(String seizureId) async {
    try {
      DocumentSnapshot seizureDoc = await FirebaseFirestore.instance
          .collection('seizure')
          .doc(seizureId)
          .get();

      if (seizureDoc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateSellingAllowancePage(seizureId: seizureId),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Seizure ID does not exist.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error verifying seizure ID: $e');
    }
  }
}
