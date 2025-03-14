import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalHusbandary {
  final String id;
  final String name;
  final String address;
  final String phone;

  AnimalHusbandary({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
  });

  // Factory method to create an instance from Firestore document snapshot
  factory AnimalHusbandary.fromDocument(DocumentSnapshot doc) {
    return AnimalHusbandary(
      id: doc['AH_id'] ?? '',
      name: doc['Name'] ?? '',
      address: doc['Address'] ?? '',
      phone: doc['Phone number'] ?? '',
    );
  }
}

class AnimalHusbandariesDataPage extends StatelessWidget {
  const AnimalHusbandariesDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Husbandaries Registered'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('animal_husbandary').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            List<AnimalHusbandary> husbandaries = snapshot.data!.docs
                .map((doc) => AnimalHusbandary.fromDocument(doc))
                .toList();

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: husbandaries.map((husbandary) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AH ID: ${husbandary.id}', style: const TextStyle(fontSize: 16)),
                                Text('Name: ${husbandary.name}', style: const TextStyle(fontSize: 16)),
                                Text('Address: ${husbandary.address}', style: const TextStyle(fontSize: 16)),
                                Text('Phone: ${husbandary.phone}', style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
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

void main() {
  runApp(const MaterialApp(home: AnimalHusbandariesDataPage()));
}
