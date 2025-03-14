import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'view_specific_details_page.dart';

class ViewRegisteredCattlePage extends StatefulWidget {
  final String id;  // This is the passed NGO ID
  const ViewRegisteredCattlePage({super.key, required this.id});

  @override
  _ViewRegisteredCattlePageState createState() =>
      _ViewRegisteredCattlePageState();
}

class _ViewRegisteredCattlePageState extends State<ViewRegisteredCattlePage> {
  final TextEditingController _ngoIdController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _taluka;
  bool _isNgoIdVerified = false;
  List<Map<String, dynamic>> _cattleData = [];

  @override
  void initState() {
    super.initState();
    _ngoIdController.text = widget.id; // Set the passed id to the NGO ID field
  }

  @override
  void dispose() {
    _ngoIdController.dispose();
    _cattleIdController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _verifyNgoId() async {
    String ngoId = _ngoIdController.text.trim();

    if (ngoId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid NGO ID')),
      );
      return;
    }

    try {
      QuerySnapshot ngoQuerySnapshot = await FirebaseFirestore.instance
          .collection('ngo')
          .where('NGO_id', isEqualTo: ngoId)
          .get();

      if (ngoQuerySnapshot.docs.isNotEmpty) {
        String ngoEmail = ngoQuerySnapshot.docs.first.get('Email');
        String ngoTaluka = ngoQuerySnapshot.docs.first.get('Taluka');
        String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

        if (ngoEmail == currentUserEmail) {
          setState(() {
            _isNgoIdVerified = true;
            _taluka = ngoTaluka;
          });

          // Fetch cattle data filtered by Taluka immediately after verification
          await _fetchCattleDataByTaluka(_taluka!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('NGO Email does not match with the current user')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid NGO ID')),
        );
      }
    } catch (e) {
      print('Error verifying NGO ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error verifying NGO ID')),
      );
    }
  }

  Future<void> _fetchCattleDataByTaluka(String taluka) async {
    try {
      // Fetch cattle data based on the Taluka
      Query<Map<String, dynamic>> cattleQuery = FirebaseFirestore.instance
          .collection('cattle')
          .where('Taluka', isEqualTo: taluka);

      // If a date is entered, filter by that date
      String formattedDate = _dateController.text.trim();
      if (formattedDate.isNotEmpty) {
        cattleQuery = cattleQuery.where('RegistrationDate', isEqualTo: formattedDate);
      }

      QuerySnapshot<Map<String, dynamic>> cattleQuerySnapshot = await cattleQuery.get();

      setState(() {
        _cattleData = cattleQuerySnapshot.docs
            .map((doc) => doc.data())
            .toList();
      });
    } catch (e) {
      print('Error fetching Cattle data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching Cattle data')),
      );
    }
  }

  void _viewSpecificDetails() {
    String cattleId = _cattleIdController.text.trim();

    if (cattleId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Cattle ID')),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('cattle')
        .doc(cattleId)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        String cattleTaluka = docSnapshot.get('Taluka');

        // Compare the Taluka of the cattle with the Taluka of the NGO
        if (cattleTaluka == _taluka) {
          // Navigate to the next page if the Talukas match
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewSpecificDetailsPage(cattleId: cattleId),
            ),
          );
        } else {
          // Show error if the Talukas do not match
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cattle is not registered under the same Taluka as the NGO')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cattle ID not found')),
        );
      }
    }).catchError((error) {
      print('Error verifying Cattle ID: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error verifying Cattle ID')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Registered Cattle'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _ngoIdController,
              decoration: const InputDecoration(
                labelText: 'NGO ID',
                border: OutlineInputBorder(),
              ),
              readOnly: true,  // Make the NGO ID field read-only
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isNgoIdVerified ? null : _verifyNgoId,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.black,
              ),
              child: const Text('Get details'),
            ),
            const SizedBox(height: 20),
            if (_isNgoIdVerified) ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Taluka',
                  border: OutlineInputBorder(),
                ),
                initialValue: _taluka,
                readOnly: true,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Enter Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _fetchCattleDataByTaluka(_taluka!);
                },
              ),
              const SizedBox(height: 20),
              if (_cattleData.isNotEmpty)
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2, // 1 card on mobile, 2 cards on larger screens
                    childAspectRatio: 1.5, // Aspect ratio of the card
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                  itemCount: _cattleData.length,
                  itemBuilder: (context, index) {
                    final cattle = _cattleData[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cattle ID: ${cattle['Cattle_id'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Owner ID: ${cattle['Owner_id'] ?? ''}'),
                            Text('Breed: ${cattle['Breed'] ?? ''}'),
                            Text('Color: ${cattle['Color'] ?? ''}'),
                            Text('Medical History: ${cattle['Medical History'] ?? ''}'),
                            Text('Registration Date: ${cattle['RegistrationDate'] ?? ''}'),
                            Text('Taluka: ${cattle['Taluka'] ?? ''}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cattleIdController,
                decoration: const InputDecoration(
                  labelText: 'Enter Cattle ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _viewSpecificDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.black,
                ),
                child: const Text('View Specific Details'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
