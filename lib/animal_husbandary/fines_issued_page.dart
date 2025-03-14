import 'package:cattle_care_app/animal_husbandary/update_payment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Define the FineIssued data model
class FineIssued {
  final String fineId;
  final String ownerId;
  final String cattleId;
  final String fineAmount; // Changed to String
  final String reason;
  final String date; // Date changed to String
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

  // Factory method to create a FineIssued object from Firestore data
  factory FineIssued.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FineIssued(
      fineId: data['fine_id'] ?? '',
      ownerId: data['owner_id'] ?? '',
      cattleId: data['cattle_id'] ?? '',
      fineAmount: (data['amount'] ?? 0.0).toString(), // Convert amount to String
      reason: data['reason'] ?? '',
      date: data['date'] ?? '', // Extract only the date part
      paymentStatus: data['status'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      ownerName: data['owner_name'] ?? '',
    );
  }
}

// Define the FinesIssuedPage as a StatefulWidget
class FinesIssuedPage extends StatefulWidget {
  const FinesIssuedPage({super.key});

  @override
  _FinesIssuedPageState createState() => _FinesIssuedPageState();
}

class _FinesIssuedPageState extends State<FinesIssuedPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fineIdController = TextEditingController();
  List<FineIssued> _allFinesIssued = []; // All fines fetched
  List<FineIssued> _filteredFinesIssued = []; // Fines filtered based on search
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchFinesIssued(); // Fetch all fines when the page loads
  }

  // Fetch fines from Firestore when the page loads
  Future<void> _fetchFinesIssued() async {
    try {
      final snapshot = await _firestore.collection('fine').get();
      final fines = snapshot.docs.map((doc) => FineIssued.fromFirestore(doc)).toList();
      setState(() {
        _allFinesIssued = fines; // Store all fetched fines
        _filteredFinesIssued = fines; // Initially display all fines
      });
    } catch (e) {
      print('Error fetching fines: $e');
    }
  }

  // Filter fines by owner_id and date
  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    final dateQuery = _dateController.text.toLowerCase();
    setState(() {
      _filteredFinesIssued = _allFinesIssued.where((fine) {
        final matchesOwnerId = fine.ownerId.toLowerCase().contains(query);
        final matchesDate = dateQuery.isEmpty || fine.date.toLowerCase().contains(dateQuery);
        return matchesOwnerId && matchesDate;
      }).toList();
    });
  }

  // Color coding based on payment status
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

  // Navigate to update payment status page
  void _navigateToUpdatePaymentStatus(String fineId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdatePaymentStatusPage(fineId: fineId),
      ),
    );

    // Check if the result indicates a successful update
    if (result == true) {
      _fetchFinesIssued(); // Refresh the fines list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fines Issued'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search bar to filter based on owner_id
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
                      _performSearch(); // Perform search on text change
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Date filter
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'Search with date',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                _performSearch(); // Perform search on date change
              },
            ),
            const SizedBox(height: 20),
            // Fine ID input and update button
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
            // Cards for fines
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 1 : 2, // 1 card on mobile, 2 on laptop
                childAspectRatio: 1.5, // Aspect ratio for card height
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
              ),
              itemCount: _filteredFinesIssued.length,
              itemBuilder: (context, index) {
                final fine = _filteredFinesIssued[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fine ID: ${fine.fineId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Owner ID: ${fine.ownerId}'),
                        Text('Cattle ID: ${fine.cattleId}'),
                        Text('Fine Amount: ${fine.fineAmount}'),
                        Text('Reason: ${fine.reason}'),
                        Text('Date: ${fine.date}'),
                        Text(
                          'Payment Status: ${fine.paymentStatus}',
                          style: TextStyle(color: _getPaymentStatusColor(fine.paymentStatus)),
                        ),
                        Text('Phone Number: ${fine.phoneNumber}'),
                        Text('Owner Name: ${fine.ownerName}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FinesIssuedPage(),
  ));
}
