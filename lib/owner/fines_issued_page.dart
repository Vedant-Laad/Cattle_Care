import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'send_query_page.dart'; // Import SendQueryPage

class FineIssued {
  final String fineId;
  final String ownerId;
  final String cattleId;
  final String fineAmount;
  final String reason;
  final String date;
  final String paymentStatus;
  final String fileComplaintId;
  final String ownerName;

  FineIssued({
    required this.fineId,
    required this.ownerId,
    required this.cattleId,
    required this.fineAmount,
    required this.reason,
    required this.date,
    required this.paymentStatus,
    required this.fileComplaintId,
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
      fileComplaintId: data['complaint_id'] ?? '',
      ownerName: data['owner_name'] ?? '',
    );
  }
}

class FinesIssuedPage extends StatefulWidget {
  final String id;
  const FinesIssuedPage({super.key,required this.id});

  @override
  _FinesIssuedPageState createState() => _FinesIssuedPageState();
}

class _FinesIssuedPageState extends State<FinesIssuedPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fineIdController = TextEditingController();
  final TextEditingController _ownerIdController = TextEditingController();
  List<FineIssued> _allFinesIssued = [];
  List<FineIssued> _filteredFinesIssued = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _ownerId = '';
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    // Set the owner ID from the passed ID
    _ownerId = widget.id; // Assign the ID passed to this page
    _ownerIdController.text = _ownerId; // Populate the owner ID text field
  }

  Future<void> _fetchFinesIssued() async {
    if (!_isVerified) return;

    try {
      final snapshot = await _firestore.collection('fine').get();
      final fines = snapshot.docs.map((doc) => FineIssued.fromFirestore(doc)).toList();
      setState(() {
        _allFinesIssued = fines.where((fine) => fine.ownerId == _ownerId).toList();
        _filteredFinesIssued = _allFinesIssued;
      });
    } catch (e) {
      print('Error fetching fines: $e');
    }
  }

  Future<void> _verifyOwnerId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently logged in')),
      );
      return;
    }

    final currentUserEmail = currentUser.email;

    try {
      final ownerSnapshot = await _firestore.collection('owner').doc(_ownerId).get();
      final ownerData = ownerSnapshot.data() as Map<String, dynamic>;

      if (ownerData['Email'] == currentUserEmail) {
        setState(() {
          _isVerified = true;
          _ownerIdController.text = _ownerId; // Populate with entered Owner ID
        });
        _fetchFinesIssued();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Owner ID verification failed')),
        );
      }
    } catch (e) {
      print('Error verifying owner ID: $e');
    }
  }

  Future<bool> _verifyFineIdOwnerId(String fineId) async {
    try {
      final fineSnapshot = await _firestore.collection('fine').doc(fineId).get();
      final fineData = fineSnapshot.data();

      if (fineData != null && fineData['owner_id'] == _ownerId) {
        return true;
      }
    } catch (e) {
      print('Error verifying fine ID: $e');
    }
    return false;
  }

  void _performSearchByDate() {
    final query = _dateController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredFinesIssued = _allFinesIssued;
      } else {
        _filteredFinesIssued = _allFinesIssued.where((fine) {
          return fine.date.contains(query);
        }).toList();
      }
    });
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Unpaid':
        return Colors.red;
      case 'Issue':
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  void _sendQuery() async {
    final fineId = _fineIdController.text;

    if (fineId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Fine ID')),
      );
      return;
    }

    final isVerified = await _verifyFineIdOwnerId(fineId);
    if (isVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SendQueryPage(fineId: fineId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fine ID verification failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines Issued'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Owner ID verification
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ownerIdController,
                      readOnly: true, // Set read-only once verified
                      decoration: const InputDecoration(
                        hintText: 'Enter Owner ID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _ownerId = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isVerified ? null : _verifyOwnerId, // Disable button after verification
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Get Details'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Date search
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Date (e.g. 2023-09-22)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        _performSearchByDate();
                      },
                    ),
                  ),
                
                ],
              ),
              const SizedBox(height: 20),
              // List of fines issued as cards
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;
                  double cardWidth = isMobile ? constraints.maxWidth : constraints.maxWidth / 2 - 10;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Allows scrolling on the whole page
                    itemCount: _filteredFinesIssued.length,
                    itemBuilder: (context, index) {
                      final fine = _filteredFinesIssued[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10,),
                          side: const BorderSide(color: Colors.blue, width: 2),
                          //side: const BorderSide(color: Colors.blue), // Blue border color
                        ),
                        child: Container(
                          width: cardWidth, // Dynamically set card width
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fine ID: ${fine.fineId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text('Owner ID: ${fine.ownerId}'),
                              Text('Cattle ID: ${fine.cattleId}'),
                              Text('Fine Amount: ${fine.fineAmount}'),
                              Text('Reason: ${fine.reason}'),
                              Text('Date: ${fine.date}'),
                              Text('Payment Status: ${fine.paymentStatus}', style: TextStyle(color: _getPaymentStatusColor(fine.paymentStatus))),
                              Text('Complaint ID: ${fine.fileComplaintId}'),
                              Text('Owner Name: ${fine.ownerName}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              // Send query section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fineIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter Fine ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sendQuery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Send Query'),
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
