import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define the Query model with Query ID, owner_name, file_complaint_id, and replies array
class Query {
  final String queryId;
  final String ownerId;
  final String cattleId;
  final String fineId;
  final String reason;
  final String amount;
  final String query;
  final String ownerName;
  final String fileComplaintId;
  final List<dynamic> replies; // Modified to handle an array of replies

  Query({
    required this.queryId,
    required this.ownerId,
    required this.cattleId,
    required this.fineId,
    required this.reason,
    required this.amount,
    required this.query,
    required this.ownerName,
    required this.fileComplaintId,
    required this.replies, // Modified to handle an array of replies
  });

  // Convert from Firestore document to Query model
  factory Query.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Query(
      queryId: data['query_id'] ?? '',
      ownerId: data['owner_id'] ?? '',
      cattleId: data['cattle_id'] ?? '',
      fineId: data['fine_id'] ?? '',
      reason: data['reason'] ?? '',
      amount: data['amount'] ?? '',
      query: data['query'] ?? '',
      ownerName: data['owner_name'] ?? '',
      fileComplaintId: data['file_complaint_id'] ?? '',
      replies: data['replies'] ?? [], // Ensuring replies is an array
    );
  }
}

// QueriesPage widget
class QueriesPage extends StatefulWidget {
  final String id; 
  const QueriesPage({super.key, required this.id});

  @override
  _QueriesPageState createState() => _QueriesPageState();
}

class _QueriesPageState extends State<QueriesPage> {
  final TextEditingController _ownerIdController = TextEditingController();
  bool _isVerified = false;
  List<Query> _allQueries = [];
  List<Query> _filteredQueries = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // FirebaseAuth instance

  @override
  void initState() {
    super.initState();
    // Set the owner ID in the text field
    _ownerIdController.text = widget.id; // Set the initial value to the ID passed
  }
  
  // ... rest of your existing code remains unchanged ...

  // Fetch queries from Firestore based on owner_id after verification
  Future<void> _fetchQueries(String ownerId) async {
    try {
      final snapshot = await _firestore
          .collection('query')
          .where('owner_id', isEqualTo: ownerId)
          .get();
      final queries = snapshot.docs.map((doc) => Query.fromFirestore(doc)).toList();
      setState(() {
        _allQueries = queries;
        _filteredQueries = queries;
      });
    } catch (e) {
      print('Error fetching queries: $e');
    }
  }

  // Verify owner_id by comparing the user's email with the owner's email from Firestore
  Future<void> _verifyOwnerId() async {
    try {
      final currentUserEmail = await _getCurrentUserEmail();
      final ownerId = _ownerIdController.text;

      // Fetch the owner's email from the 'owner' collection using the owner_id
      final ownerSnapshot = await _firestore
          .collection('owner')
          .where('Owner_id', isEqualTo: ownerId)
          .limit(1)
          .get();

      if (ownerSnapshot.docs.isNotEmpty) {
        final ownerData = ownerSnapshot.docs.first.data();
        final ownerEmail = ownerData['Email'] ?? '';

        // Verify if the current user's email matches the owner's email
        if (currentUserEmail == ownerEmail) {
          setState(() {
            _isVerified = true;
          });
          // Fetch the queries for this owner
          _fetchQueries(ownerId);
        } else {
          setState(() {
            _isVerified = false;
          });
          _showErrorDialog('Verification failed: Email mismatch.');
        }
      } else {
        _showErrorDialog('Owner not found.');
      }
    } catch (e) {
      print('Error verifying owner: $e');
    }
  }

  // Fetch the current user's email using Firebase Auth
  Future<String> _getCurrentUserEmail() async {
    final User? user = _auth.currentUser; // Get the current user
    if (user != null) {
      return user.email ?? ''; // Return the user's email
    } else {
      throw Exception('No user is currently signed in');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show reply dialog
  // Show reply dialog
// Show reply dialog with validation
// Show reply dialog
void _showReplyDialog(BuildContext context, Query query) {
  final TextEditingController replyController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Reply to Query'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reply to Query ID: ${query.queryId}'),
            const SizedBox(height: 10),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your reply',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              final reply = replyController.text.trim();
              // Validate reply input
              if (_isValidReply(reply)) {
                _addReplyToQuery(query.queryId, reply);
                Navigator.of(context).pop();
              } else {
                _showErrorDialog('Reply must contain at least one alphabetic character.');
              }
            },
            child: const Text('Send', style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );
}

// Validate the reply input
bool _isValidReply(String reply) {
  // Regular expression to check for at least one alphabetic character
  final regex = RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9 .?,()/]*$');
  return regex.hasMatch(reply);
}

// Add reply to Firestore with prefix "owner:"
Future<void> _addReplyToQuery(String queryId, String reply) async {
  try {
    final replyWithPrefix = 'owner: $reply';
    final queryRef = _firestore.collection('query').doc(queryId);

    // Update the replies array with the new reply
    await queryRef.update({
      'replies': FieldValue.arrayUnion([replyWithPrefix])
    });

    // Fetch the updated list of queries
    _fetchQueries(_ownerIdController.text);
  } catch (e) {
    print('Error adding reply: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queries'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Owner ID text field and verification button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ownerIdController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        hintText: 'Enter owner_id',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isVerified ? null : _verifyOwnerId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Get Details'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _filteredQueries.isEmpty
                  ? const Center(child: Text('No queries found.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = MediaQuery.of(context).size.width < 600; // Check if the width is less than 600
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredQueries.length,
                          itemBuilder: (context, index) {
                            final query = _filteredQueries[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.blue, width: 2),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                width: isMobile ? double.infinity : constraints.maxWidth / 2, // Adjust width based on device
                                child: ListTile(
                                  title: Text('Query ID: ${query.queryId}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Owner ID: ${query.ownerId}'),
                                      Text('Owner Name: ${query.ownerName}'),
                                      Text('Cattle ID: ${query.cattleId}'),
                                      Text('Fine ID: ${query.fineId}'),
                                      Text('Reason: ${query.reason}'),
                                      Text('Amount: ${query.amount}'),
                                      Text('Query: ${query.query}'),
                                      if (query.replies.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text('Replies:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        for (var reply in query.replies) 
                                          Text(reply),
                                      ],
                                    ],
                                  ),
                                  trailing: ElevatedButton.icon(
                                    onPressed: () {
                                      _showReplyDialog(context, query);
                                    },
                                    icon: const Icon(Icons.reply),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.black,
                                    ),
                                    label: const Text('Reply'),
                                  ),
                                ),
                              ),
                            );
                          },
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
