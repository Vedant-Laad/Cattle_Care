import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cattle_care_app/user/qr_scanner.dart'; // Import your QR scanner

class CattlesOwnedPage extends StatefulWidget {
  final String id;
  const CattlesOwnedPage({super.key, required this.id});

  @override
  _CattlesOwnedPageState createState() => _CattlesOwnedPageState();
}

class _CattlesOwnedPageState extends State<CattlesOwnedPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _cattleIdController = TextEditingController();
  late CollectionReference _cattleCollection;
  bool _isOwnerVerified = false;
  String? _verifiedOwnerId;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.id; // Set the owner_id text field with the ID
    _cattleCollection = FirebaseFirestore.instance.collection('cattle');
  }

  Future<void> _verifyOwnerId() async {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reg_owner')
        .where('Email', isEqualTo: currentUserEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String ownerId = querySnapshot.docs.first['Owner_id'];
      if (_searchController.text == ownerId) {
        setState(() {
          _isOwnerVerified = true;
          _verifiedOwnerId = ownerId; // Store the verified owner ID
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID is incorrect.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No account associated with this email.')),
      );
    }
  }

  Future<void> _scanQRCode() async {
    String scannedCattleId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRScanner()),
    );

    if (scannedCattleId.isNotEmpty) {
      _cattleIdController.text = scannedCattleId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattles Owned'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Search bar for Owner ID
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Enter owner_id',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Disable if owner is verified
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isOwnerVerified ? null : _verifyOwnerId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Get details',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // New TextField for Cattle ID (Read-only)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cattleIdController,
                      decoration: const InputDecoration(
                        hintText: 'Cattle ID',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Make it read-only
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _scanQRCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Scan QR',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Add Filter button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // Trigger the filtering logic by calling setState
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Filter',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // StreamBuilder to fetch data from Firestore
              _isOwnerVerified
                  ? StreamBuilder<QuerySnapshot>(
                      stream: _cattleCollection.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        // Filter the cattle list based on the verified owner ID and cattle ID
                        List<QueryDocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
                          final ownerId = doc['Owner_id'].toString().toLowerCase();
                          final cattleId = doc['Cattle_id'].toString().toLowerCase();
                          final enteredCattleId = _cattleIdController.text.toLowerCase();

                          // Check if owner ID matches
                          bool isOwnerMatch = ownerId == _verifiedOwnerId?.toLowerCase();
                          // Check if cattle ID matches
                          bool isCattleIdMatch = enteredCattleId.isEmpty || cattleId == enteredCattleId;

                          return isOwnerMatch && isCattleIdMatch;
                        }).toList();

                        // Determine card color based on number of fines
                        Color getCardColor(int numberOfFines) {
                          if (numberOfFines == 0) {
                            return Colors.white;
                          } else if (numberOfFines == 1) {
                            return Colors.yellow;
                          } else if (numberOfFines == 2) {
                            return Colors.orange;
                          } else {
                            return Colors.red;
                          }
                        }

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWideScreen = constraints.maxWidth > 600; // Adjust based on screen width

                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: filteredDocs.map((doc) {
                                final cattleId = doc['Cattle_id'];
                                final ownerId = doc['Owner_id'];
                                final breed = doc['Breed'];
                                final color = doc['Color'];
                                final medicalHistory = doc['Medical History'];
                                final numberOfFinesIssued = doc['Number_of_Fines_Issued'];

                                return Container(
                                  width: isWideScreen ? (constraints.maxWidth / 2 - 10) : constraints.maxWidth,
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                    color: getCardColor(numberOfFinesIssued),
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Cattle ID: $cattleId'),
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
                        );
                      },
                    )
                  : const Center(child: Text('Please verify your owner ID to see cattle details.')),
            ],
          ),
        ),
      ),
    );
  }
}
