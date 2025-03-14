import 'package:cattle_care_app/cattle_seizure/cattle_seizure_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

class CattleSeizureAllowancePage extends StatefulWidget {
  final String id;
  const CattleSeizureAllowancePage({super.key,required this.id});

  @override
  _CattleSeizureAllowancePageState createState() => _CattleSeizureAllowancePageState();
}

class _CattleSeizureAllowancePageState extends State<CattleSeizureAllowancePage> {
  final TextEditingController _cattleIdController = TextEditingController();
  late CollectionReference _cattleCollection;

  @override
  void initState() {
    super.initState();
    _cattleCollection = FirebaseFirestore.instance.collection('cattle');
  }

  void _navigateToCattleSeizurePage() async {
    final cattleId = _cattleIdController.text.trim();
    if (cattleId.isNotEmpty) {
      // Check if the document with the given cattle ID exists
      final docSnapshot = await _cattleCollection.doc(cattleId).get();

      if (docSnapshot.exists) {
        // Navigate to the CattleSeizurePage if the document exists
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CattleSeizurePage(cattleId: cattleId,id:widget.id),
          ),
        );
      } else {
        // Show error if cattle_id does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle ID does not exist.')),
        );
      }
    } else {
      // Show error if cattle_id is not entered
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Cattle ID.')),
      );
    }
  }

  Color _getCardColor(int numberOfFines) {
    // Determine card color based on the number of fines issued
    if (numberOfFines == 0) {
      return Colors.white; // White for 0 fines
    } else if (numberOfFines == 1) {
      return Colors.yellow; // Yellow for 1 fine
    } else if (numberOfFines == 2) {
      return Colors.orange; // Orange for 2 fines
    } else {
      return Colors.red; // Red for 3 or more fines
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattle Seizure Allowance'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Enable scrolling for the entire page
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TextField for Cattle ID
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cattleIdController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Cattle ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            // Button to navigate to Seizure Page
            ElevatedButton(
              onPressed: _navigateToCattleSeizurePage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Seize Cattle',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            // StreamBuilder to fetch cattle data
            StreamBuilder<QuerySnapshot>(
              stream: _cattleCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs.toList();

                return Wrap( // Use Wrap to create a list of cards
                  spacing: 20.0, // Space between cards
                  runSpacing: 20.0, // Space between rows
                  children: docs.map((doc) {
                    final cattleId = doc['Cattle_id'];
                    final ownerId = doc['Owner_id'];
                    final breed = doc['Breed'];
                    final color = doc['Color'];
                    final medicalHistory = doc['Medical History'];
                    final numberOfFinesIssued = doc['Number_of_Fines_Issued'] as int;

                    return Container(
                      width: kIsWeb ? MediaQuery.of(context).size.width * 0.45 : double.infinity, // Adjust width for mobile and desktop
                      child: Card(
                        color: _getCardColor(numberOfFinesIssued), // Set card color based on fines issued
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cattle ID: $cattleId', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Owner ID: $ownerId'),
                              Text('Breed: $breed'),
                              Text('Color: $color'),
                              Text('Medical History: $medicalHistory'),
                              Text('Number of Fines: $numberOfFinesIssued'),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
