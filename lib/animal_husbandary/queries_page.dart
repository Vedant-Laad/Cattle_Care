import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Define the Query model
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
  final List<String> replies;

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
    this.replies = const [],
  });

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
      replies: List<String>.from(data['replies'] ?? []),
    );
  }
}

// QueriesPage widget
class QueriesPage extends StatefulWidget {
  const QueriesPage({super.key});

  @override
  _QueriesPageState createState() => _QueriesPageState();
}

class _QueriesPageState extends State<QueriesPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Query> _allQueries = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<List<Query>> _queryStream;

  @override
  void initState() {
    super.initState();
    _queryStream = _fetchQueries();
  }

  // Listen for real-time updates from Firestore
  Stream<List<Query>> _fetchQueries() {
    return _firestore.collection('query').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Query.fromFirestore(doc)).toList();
    });
  }

  // Filter the queries by owner_id
  List<Query> _performSearch(List<Query> queries) {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return queries;
    return queries.where((q) => q.ownerId.toLowerCase().contains(query)).toList();
  }

// Show alert dialog for validation errors
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Validation Error'),
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

// Validation function for reply
bool _validateReply(String reply, BuildContext context) {
  final RegExp regex = RegExp(
    r'^(?=.*[a-zA-Z]).*$',  // At least one letter must be present
  );

  if (reply.isEmpty || !regex.hasMatch(reply)) {
    _showErrorDialog(context, 'Please enter a valid reply (must contain letters and can include digits or special symbols)');
    return false; // Validation failed
  }
  return true; // Validation succeeded
}

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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reply = replyController.text;
              if (reply.isNotEmpty && _validateReply(reply, context)) { // Check for validation
                try {
                  final prefixedReply = 'AH: $reply';
                  await _firestore.collection('query').doc(query.queryId).update({
                    'replies': FieldValue.arrayUnion([prefixedReply]),
                  });
                  print('Reply sent to Query ID ${query.queryId}: $prefixedReply');
                } catch (e) {
                  print('Error sending reply: $e');
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('Send'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queries'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Wrap entire body in SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
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
                        setState(() {}); // Trigger a rebuild on search
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<Query>>(
                stream: _queryStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No queries found.'));
                  }

                  final queries = snapshot.data!;
                  final filteredQueries = _performSearch(queries);

                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Prevent scrolling of inner ListView
                    shrinkWrap: true, // Use available height
                    itemCount: filteredQueries.length,
                    itemBuilder: (context, index) {
                      final query = filteredQueries[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Query ID: ${query.queryId}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Owner ID: ${query.ownerId}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('Owner Name: ${query.ownerName}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('Cattle ID: ${query.cattleId}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('Fine ID: ${query.fineId}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('File Complaint ID: ${query.fileComplaintId}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('Reason: ${query.reason}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('Amount: ${query.amount}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              Text('Query: ${query.query}',style: const TextStyle(fontWeight:FontWeight.bold,),),
                              const SizedBox(height: 10),
                              if (query.replies.isNotEmpty) ...[
                                const Text('Replies:', style: TextStyle(fontWeight: FontWeight.bold)),
                                ...query.replies.map((reply) => Text(reply)),
                              ],
                            ],
                          ),
                          isThreeLine: true,
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