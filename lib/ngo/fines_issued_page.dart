import 'package:cattle_care_app/animal_husbandary/update_payment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Define the FineIssued data model
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
  final String taluka;

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
    required this.taluka,
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
      taluka: data['taluka'] ?? '',
    );
  }
}

class FinesIssuedPage extends StatefulWidget {
  final String id; // Accept id
  const FinesIssuedPage({super.key,required this.id});

  @override
  _FinesIssuedPageState createState() => _FinesIssuedPageState();
}

class _FinesIssuedPageState extends State<FinesIssuedPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fineIdController = TextEditingController();
  final TextEditingController _ngoIdController = TextEditingController();
  final TextEditingController _ngoTalukaController = TextEditingController(); // Taluka field
  List<FineIssued> _allFinesIssued = [];
  List<FineIssued> _filteredFinesIssued = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserEmail;
  bool _isNgoVerified = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _ngoIdController.text = widget.id;
    _fetchCurrentUserEmail();
  }

  Future<void> _fetchCurrentUserEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserEmail = user.email;
      });
    }
  }

  Future<void> _fetchFinesIssued({String? ngoTaluka}) async {
    try {
      final snapshot = await _firestore.collection('fine').get();
      final fines = snapshot.docs.map((doc) => FineIssued.fromFirestore(doc)).toList();
      setState(() {
        _allFinesIssued = fines;
        if (ngoTaluka != null) {
          _filteredFinesIssued = fines.where((fine) => fine.taluka == ngoTaluka).toList();
        } else {
          _filteredFinesIssued = fines; // No filtering if no Taluka provided
        }
      });
    } catch (e) {
      print('Error fetching fines: $e');
    }
  }

  Future<void> _verifyNgoId() async {
    final ngoId = _ngoIdController.text.trim();
    if (ngoId.isNotEmpty) {
      try {
        final ngoDoc = await _firestore.collection('ngo').doc(ngoId).get();
        if (ngoDoc.exists) {
          final ngoData = ngoDoc.data() as Map<String, dynamic>;
          final ngoTaluka = ngoData['Taluka'] ?? '';

          if (ngoData['Email'] == _currentUserEmail) {
            setState(() {
              _isNgoVerified = true;
              _ngoTalukaController.text = ngoTaluka; // Set the Taluka
              _ngoIdController.text = ngoId; // Set the NGO ID
            });
            // Fetch fines after verification and filter by Taluka
            _fetchFinesIssued(ngoTaluka: ngoTaluka);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email does not match the current user.')),
            );
          }
        }
      } catch (e) {
        print('Error verifying NGO ID: $e');
      }
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    final ngoTaluka = _ngoTalukaController.text.toLowerCase();

    setState(() {
      // Filter by taluka and owner ID
      _filteredFinesIssued = _allFinesIssued.where((fine) {
        final matchesTaluka = fine.taluka.toLowerCase() == ngoTaluka;
        final matchesOwnerId = fine.ownerId.toLowerCase().contains(query);
        return matchesTaluka && matchesOwnerId;
      }).toList();
    });
  }

  Future<void> _navigateToUpdatePaymentStatus(String fineId) async {
    try {
      final fineDoc = await _firestore.collection('fine').doc(fineId).get();
      if (fineDoc.exists) {
        final fineData = fineDoc.data() as Map<String, dynamic>;
        final fineTaluka = fineData['taluka'] ?? '';

        // Check if NGO taluka matches
        if (fineTaluka == _ngoTalukaController.text) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdatePaymentStatusPage(fineId: fineId),
            ),
          );

          if (result == true) {
            _fetchFinesIssued(ngoTaluka: _ngoTalukaController.text); // Refresh fines
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('NGO Taluka does not match the fine\'s Taluka.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fine ID not found.')),
        );
      }
    } catch (e) {
      print('Error fetching fine data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines Issued'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Enable scrolling for the entire page
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ngoIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter NGO ID',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true, // Make NGO ID read-only if verified
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _verifyNgoId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: const Color.fromRGBO(0, 0, 0, 1),
                    ),
                    child: const Text('Get Details'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isNgoVerified) ...[
                TextField(
                  controller: _ngoTalukaController,
                  decoration: const InputDecoration(
                    labelText: 'NGO Taluka',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search with owner_id',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        _performSearch();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fineIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Fine ID to Update Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final fineId = _fineIdController.text.trim();
                      if (fineId.isNotEmpty) {
                        _navigateToUpdatePaymentStatus(fineId);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Update Status'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredFinesIssued.length,
                itemBuilder: (context, index) {
                  final fine = _filteredFinesIssued[index];
                  Color textColor;

                  // Set the text color based on payment status
                  switch (fine.paymentStatus) {
                    case 'Paid':
                      textColor = Colors.green; // Green for paid
                      break;
                    case 'Unpaid':
                      textColor = Colors.red; // Orange for pending
                      break;
                    default:
                      textColor = Colors.black; // Default color
                      break;
                  }

                  return Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.blue, width: 2), // Blue border
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    child: ListTile(
                      title: Text('Fine ID: ${fine.fineId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Owner ID: ${fine.ownerId}'),
                          Text('Cattle ID: ${fine.cattleId}'),
                          Text('Fine Amount: ₹${fine.fineAmount}'),
                          Text('Reason: ${fine.reason}'),
                          Text('Date: ${fine.date}'),
                          Text(
                            'Payment Status: ${fine.paymentStatus}',
                            style: TextStyle(color: textColor), // Use dynamic color
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
