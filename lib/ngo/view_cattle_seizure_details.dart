import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cattle_care_app/ngo/update_cattle_seizure_details_page.dart'; // Import the Update Cattle Seizure Details Page

class ViewSeizureDetailsPage extends StatefulWidget {
  final String id;
  const ViewSeizureDetailsPage({super.key,required this.id});

  @override
  _ViewSeizureDetailsPageState createState() => _ViewSeizureDetailsPageState();
}

class _ViewSeizureDetailsPageState extends State<ViewSeizureDetailsPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController seizureIdController = TextEditingController();
  final TextEditingController ngoIdController = TextEditingController();

  String? verifiedNgoId;
  String? taluka;
  List<DocumentSnapshot> filteredDetails = [];
  List<DocumentSnapshot> seizureDetails = []; // Store all seizure details
  bool isNgoVerified = false;

  @override
  void initState() {
    super.initState();
    ngoIdController.text = widget.id; // Set the passed id to the NGO ID field
    // Fetch data once on init
    fetchSeizureDetails();
  }

  Future<void> fetchSeizureDetails() async {
    FirebaseFirestore.instance.collection('seizure').snapshots().listen((snapshot) {
      setState(() {
        seizureDetails = snapshot.docs; // Store all seizure data
        applyFilters(); // Apply filter initially or after fetching
      });
    });
  }

  Future<void> verifyNgoId() async {
    String ngoId = ngoIdController.text.trim();
    if (ngoId.isEmpty) {
      return;
    }

    try {
      DocumentSnapshot ngoDoc = await FirebaseFirestore.instance.collection('ngo').doc(ngoId).get();
      if (ngoDoc.exists) {
        String ngoEmail = ngoDoc['Email'];
        String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

        if (ngoEmail == currentUserEmail) {
          setState(() {
            verifiedNgoId = ngoId;
            taluka = ngoDoc['Taluka'];
            isNgoVerified = true; // Mark the NGO ID as verified
            applyFilters(); // Apply the filter after NGO verification
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NGO ID verification failed.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO ID does not exist.')),
        );
      }
    } catch (e) {
      print('Error verifying NGO ID: $e');
    }
  }

  void applyFilters() {
    String dateQuery = dateController.text.trim();
    
    // Apply filtering based on Taluka and Date
    setState(() {
      filteredDetails = seizureDetails.where((seizure) {
        final dateOfSeizure = seizure['date_of_seizure_allowance'] as String?;
        return seizure['taluka'] == taluka && (dateOfSeizure?.contains(dateQuery) ?? false);
      }).toList();
    });
  }

  Future<void> validateSeizureIdAndNavigate() async {
    String seizureId = seizureIdController.text.trim();
    if (seizureId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a seizure ID.')),
      );
      return;
    }

    try {
      DocumentSnapshot seizureDoc = await FirebaseFirestore.instance.collection('seizure').doc(seizureId).get();
      if (seizureDoc.exists) {
        if (seizureDoc['taluka'] == taluka) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateCattleSeizureDetailsPage(seizureId: seizureId), // Pass seizure ID to the next page
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Taluka does not match.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seizure ID does not exist.')),
        );
      }
    } catch (e) {
      print('Error validating seizure ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Seizure Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: ngoIdController,
                decoration: const InputDecoration(labelText: 'Enter NGO ID'),
                readOnly: true, // Make NGO ID read-only if verified
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: verifyNgoId, // Verify the NGO ID
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Get details'),
              ),
              const SizedBox(height: 10),
              if (isNgoVerified) ...[ // Show Taluka field only if NGO ID is verified
                Text('Verified NGO ID: $verifiedNgoId'),
                Text('Taluka: $taluka'),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Enter Date (YYYY-MM-DD)'),
                onChanged: (value) {
                  applyFilters(); // Apply filtering as the user types
                },
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2, // 1 card for mobile, 2 for larger screens
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredDetails.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot seizure = filteredDetails[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.blue, width: 2), // Blue border
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: ${seizure['address'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Allowance to Seizure: ${seizure['allowance_to_seizure'] ?? ''}'),
                          Text('Allowance to Sell: ${seizure['allowance_to_sell'] ?? ''}'),
                          Text('Cattle ID: ${seizure['cattle_id'] ?? ''}'),
                          Text('Date of Seizure: ${seizure['date_of_seizure_allowance'] ?? ''}'),
                          Text('Owner ID: ${seizure['owner_id'] ?? ''}'),
                          Text('Phone: ${seizure['phone'] ?? ''}'),
                          Text('Seizure ID: ${seizure['seizure_id'] ?? ''}'),
                          Text('Status of Seizure: ${seizure['status_of_seizure'] ?? ''}'),
                          Text('Taluka: ${seizure['taluka'] ?? ''}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Return to the previous page
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Return to Home'),
              ),
              const SizedBox(height: 20), // Add some spacing before the next button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: seizureIdController,
                      decoration: const InputDecoration(labelText: 'Enter Seizure ID'),
                    ),
                  ),
                  const SizedBox(width: 10), // Add some spacing between the text field and button
                  ElevatedButton(
                    onPressed: validateSeizureIdAndNavigate, // Validate seizure ID and navigate
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Update Seizure Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
