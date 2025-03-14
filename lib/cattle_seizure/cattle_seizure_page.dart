import 'package:cattle_care_app/animal_husbandary/animal_husbandary_homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Redirect to home page after submission

class CattleSeizurePage extends StatefulWidget {
  final String cattleId;
  final String id;

  const CattleSeizurePage({super.key, required this.cattleId,required this.id});

  @override
  _CattleSeizurePageState createState() => _CattleSeizurePageState();
}

class _CattleSeizurePageState extends State<CattleSeizurePage> {
  TextEditingController seizureIdController = TextEditingController();
  TextEditingController cattleIdController = TextEditingController();
  TextEditingController ownerIdController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController talukaController = TextEditingController(); // Added Taluka Controller
  TextEditingController allowanceToSeizureController = TextEditingController();
  TextEditingController statusOfSeizureController = TextEditingController();
  TextEditingController dateOfSeizureController = TextEditingController();

  String? selectedAllowanceToSell;

  @override
  void initState() {
    super.initState();
    cattleIdController.text = widget.cattleId;
    fetchOwnerDetails();
    generateSeizureId(); // Generate the seizure_id on initialization

    // Set default values for read-only fields
    allowanceToSeizureController.text = 'Yes';
    statusOfSeizureController.text = 'Not Seized';
    dateOfSeizureController.text = DateTime.now().toLocal().toString().split(' ')[0];
  }

  // Function to fetch owner details based on cattle_id
  Future<void> fetchOwnerDetails() async {
    try {
      DocumentSnapshot cattleSnapshot = await FirebaseFirestore.instance
          .collection('cattle')
          .doc(widget.cattleId)
          .get();

      if (cattleSnapshot.exists) {
        String ownerId = cattleSnapshot['Owner_id'];
        ownerIdController.text = ownerId;

        DocumentSnapshot ownerSnapshot = await FirebaseFirestore.instance
            .collection('owner')
            .doc(ownerId)
            .get();

        if (ownerSnapshot.exists) {
          addressController.text = ownerSnapshot['Address'];
          phoneController.text = ownerSnapshot['Phone Number'];
          talukaController.text = ownerSnapshot['Taluka']; // Fetch Taluka
        }
      }
    } catch (e) {
      print('Error fetching owner details: $e');
    }
  }

  // Function to generate seizure_id by querying the seizure collection
  Future<void> generateSeizureId() async {
    try {
      QuerySnapshot seizureSnapshot = await FirebaseFirestore.instance
          .collection('seizure')
          .get();

      int count = seizureSnapshot.docs.length + 1;
      String seizureId = 'S_${count.toString().padLeft(3, '0')}';
      seizureIdController.text = seizureId;
    } catch (e) {
      print('Error generating seizure_id: $e');
    }
  }

  // Function to save details to Firestore and show dialog
  Future<void> submitSeizureDetails() async {
    try {
      // Save details in 'seizure' collection
      await FirebaseFirestore.instance
          .collection('seizure')
          .doc(seizureIdController.text)
          .set({
        'seizure_id': seizureIdController.text,
        'cattle_id': cattleIdController.text,
        'owner_id': ownerIdController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'taluka': talukaController.text, // Add Taluka to the Firestore document
        'allowance_to_seizure': allowanceToSeizureController.text,
        'status_of_seizure': statusOfSeizureController.text,
        'allowance_to_sell': selectedAllowanceToSell,
        'date_of_seizure_allowance': dateOfSeizureController.text,
      });

      // Show dialog upon successful submission
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Seizure Passed'),
            content: const Text('Seizure orders have been passed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  AnimalHusbandaryHomePage(id:widget.id),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving seizure details: $e');
    }
  }
// Function to validate and submit the form
Future<void> validateAndSubmitSeizureDetails() async {
  if (selectedAllowanceToSell == null) {
    // Show an error if 'Allowance to Sell' is not selected
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select an option for Allowance to Sell.'),
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
    return;
  }

  // Call the submitSeizureDetails function if validation is passed
  await submitSeizureDetails();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Cattle Seizure Page'),
      backgroundColor: Colors.blue,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: seizureIdController,
                  decoration: const InputDecoration(labelText: 'Seizure ID'),
                  readOnly: true,
                ),
                TextField(
                  controller: cattleIdController,
                  decoration: const InputDecoration(labelText: 'Cattle ID'),
                  readOnly: true,
                ),
                TextField(
                  controller: ownerIdController,
                  decoration: const InputDecoration(labelText: 'Owner ID'),
                  readOnly: true,
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  readOnly: true,
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  readOnly: true,
                ),
                TextField(
                  controller: talukaController, // Added Taluka Field
                  decoration: const InputDecoration(labelText: 'Taluka'),
                  readOnly: true,
                ),
                TextField(
                  controller: allowanceToSeizureController,
                  decoration: const InputDecoration(labelText: 'Allowance to Seizure'),
                  readOnly: true,
                ),
                TextField(
                  controller: statusOfSeizureController,
                  decoration: const InputDecoration(labelText: 'Status of Seizure'),
                  readOnly: true,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Allowance to Sell'),
                  value: selectedAllowanceToSell,
                  items: ['Yes', 'No']
                      .map((option) =>
                          DropdownMenuItem<String>(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAllowanceToSell = value;
                    });
                  },
                ),
                TextField(
                  controller: dateOfSeizureController,
                  decoration: const InputDecoration(labelText: 'Date of Seizure Allowance'),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: validateAndSubmitSeizureDetails, // Updated button handler
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Submit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}