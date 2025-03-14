import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Owner {
  final String ownerId;
  final String name;
  final String address;
  final String phoneNumber;
  final String dob;

  Owner({
    required this.ownerId,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.dob,
  });

  factory Owner.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Owner(
      ownerId: doc.id,
      name: data['Name'],
      address: data['Address'],
      phoneNumber: data['Phone Number'],
      dob: data['DOB'],
    );
  }
}

class Cattle {
  final String cattleId;
  final String ownerId;
  final String breed;
  final String color;
  final int numberOfFinesIssued;
  final String medicalHistory;

  Cattle({
    required this.cattleId,
    required this.ownerId,
    required this.breed,
    required this.color,
    required this.numberOfFinesIssued,
    required this.medicalHistory,
  });

  factory Cattle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Cattle(
      cattleId: doc.id,
      ownerId: data['Owner_id'],
      breed: data['Breed'],
      color: data['Color'],
      numberOfFinesIssued: data['Number_of_Fines_Issued'] ?? 0,
      medicalHistory: data['Medical History'] ?? 'No medical history',
    );
  }
}

class ViewOwnerCattlePage extends StatefulWidget {
  const ViewOwnerCattlePage({super.key});

  @override
  _ViewOwnerCattlePageState createState() => _ViewOwnerCattlePageState();
}

class _ViewOwnerCattlePageState extends State<ViewOwnerCattlePage> {
  final TextEditingController _ownerSearchController = TextEditingController();
  final TextEditingController _cattleSearchController = TextEditingController();
  String _ownerSearchQuery = '';
  String _cattleSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Owner and Cattle Data'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search field and button for owners
            _buildSearchField(
              controller: _ownerSearchController,
              hintText: 'Search using owner name',
              onChanged: (text) {
                setState(() {
                  _ownerSearchQuery = text;
                });
              },
              onSearchPressed: () {
                setState(() {
                  _ownerSearchQuery = _ownerSearchController.text;
                });
              },
            ),
            const SizedBox(height: 20),
            // Owner details cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('owner')
                  .where('Name', isGreaterThanOrEqualTo: _ownerSearchQuery)
                  .where('Name', isLessThanOrEqualTo: '$_ownerSearchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Owner> owners = snapshot.data!.docs
                    .map((doc) => Owner.fromFirestore(doc))
                    .toList();

                return _buildOwnerCards(owners);
              },
            ),
            const SizedBox(height: 20),
            // Search field and button for cattle
            _buildSearchField(
              controller: _cattleSearchController,
              hintText: 'Search based on owner_id',
              onChanged: (text) {
                setState(() {
                  _cattleSearchQuery = text;
                });
              },
              onSearchPressed: () {
                setState(() {
                  _cattleSearchQuery = _cattleSearchController.text;
                });
              },
            ),
            const SizedBox(height: 20),
            // Cattle details cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cattle')
                  .where('Owner_id', isGreaterThanOrEqualTo: _cattleSearchQuery.isEmpty ? null : _cattleSearchQuery)
                  .where('Owner_id', isLessThanOrEqualTo: _cattleSearchQuery.isEmpty ? null : '$_cattleSearchQuery\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<Cattle> cattle = snapshot.data!.docs
                    .map((doc) => Cattle.fromFirestore(doc))
                    .toList();

                return _buildCattleCards(cattle);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
    required VoidCallback onSearchPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

Widget _buildOwnerCards(List<Owner> owners) {
  return ListView.builder(
    itemCount: owners.length,
    shrinkWrap: true, // Use available space
    physics: NeverScrollableScrollPhysics(), // Prevent scrolling
    itemBuilder: (context, index) {
      final owner = owners[index];
      return Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Owner ID: ${owner.ownerId}'),
              Text('Name: ${owner.name}'),
              Text('Address: ${owner.address}'),
              Text('Phone Number: ${owner.phoneNumber}'),
              Text('DOB: ${owner.dob}'),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildCattleCards(List<Cattle> cattle) {
  return ListView.builder(
    itemCount: cattle.length,
    shrinkWrap: true, // Use available space
    physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
    itemBuilder: (context, index) {
      final cattleItem = cattle[index];

      // Determine the color based on the number of fines issued
      Color cardColor;
      if (cattleItem.numberOfFinesIssued == 0) {
        cardColor = Colors.white; // White for 0 fines
      } else if (cattleItem.numberOfFinesIssued == 1) {
        cardColor = Colors.yellow; // Yellow for 1 fine
      } else if (cattleItem.numberOfFinesIssued == 2) {
        cardColor = Colors.orange; // Orange for 2 fines
      } else {
        cardColor = Colors.red; // Red for 3 or more fines
      }

      return Card(
        elevation: 5,
        color: cardColor, // Set the card color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cattle ID: ${cattleItem.cattleId}'),
              Text('Owner ID: ${cattleItem.ownerId}'),
              Text('Breed: ${cattleItem.breed}'),
              Text('Color: ${cattleItem.color}'),
              Text('Medical History: ${cattleItem.medicalHistory}'),
              Text('Fines Issued: ${cattleItem.numberOfFinesIssued}'),
            ],
          ),
        ),
      );
    },
  );
}



}
