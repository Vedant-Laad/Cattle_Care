import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// NGO model
class NGO {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String taluka; // New property

  NGO({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.taluka, // Initialize new property
  });

  // Factory constructor to create an NGO instance from a Firestore document
  factory NGO.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NGO(
      id: data['NGO_id'] ?? '',
      name: data['Name'] ?? '',
      address: data['Address'] ?? '',
      phone: data['Phone number'] ?? '',
      taluka: data['Taluka'] ?? '', // Fetch Taluka
    );
  }
}

class NGOsRegisteredPage extends StatelessWidget {
  const NGOsRegisteredPage({super.key});

  // Function to fetch data from Firestore
  Stream<List<NGO>> _fetchNGOs() {
    return FirebaseFirestore.instance.collection('ngo').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => NGO.fromFirestore(doc)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NGOs Registered"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<List<NGO>>(
          stream: _fetchNGOs(), // Fetching NGOs from Firestore
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data.'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No NGOs registered.'));
            }

            // Data is available
            List<NGO> ngos = snapshot.data!;

            return SingleChildScrollView(
              child: Wrap(
                spacing: 20.0, // Space between cards
                runSpacing: 20.0, // Space between rows
                children: ngos.map((ngo) {
                  return Container(
                    width: MediaQuery.of(context).size.width < 600
                        ? double.infinity // Full width for mobile
                        : (MediaQuery.of(context).size.width / 2) - 30, // Half width for larger screens
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "NGO ID: ${ngo.id}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("Name: ${ngo.name}"),
                            Text("Address: ${ngo.address}"),
                            Text("Phone: ${ngo.phone}"),
                            Text("Taluka: ${ngo.taluka}"), // New data cell
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
