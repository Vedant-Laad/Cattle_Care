import 'package:cattle_care_app/animal_husbandary/animal_husbandary_homepage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAnimalHusbandaryPage extends StatefulWidget {
  const CreateAnimalHusbandaryPage({super.key});

  @override
  _CreateAnimalHusbandaryPageState createState() => _CreateAnimalHusbandaryPageState();
}

class _CreateAnimalHusbandaryPageState extends State<CreateAnimalHusbandaryPage> {
  final _ahIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? selectedTaluka; // Variable to store selected Taluka
  final List<String> _talukas = [
    'Pernem', 'Bardez', 'Bicholim', 'Satari', 'Tiswadi', 
    'Ponda', 'Murmgao', 'Salcete', 'Sanguem', 'Quepem', 
    'Dharbandora', 'Canacona'
  ];

  @override
  void initState() {
    super.initState();
    _generateAnimalHusbandaryId(); // Generate the AH ID when the form loads
  }

  Future<void> _generateAnimalHusbandaryId() async {
    try {
      final querySnapshot = await _firestore
          .collection('animal_husbandary')
          .orderBy('AH_id', descending: true)
          .limit(1)
          .get();

      String newAhId = 'AH_001'; // Default ID if no documents exist

      if (querySnapshot.docs.isNotEmpty) {
        final lastId = querySnapshot.docs.first['AH_id'] as String;
        final lastIdNumber = int.parse(lastId.split('_').last); // Extract the number
        final nextIdNumber = lastIdNumber + 1; // Increment the number
        newAhId = 'AH_${nextIdNumber.toString().padLeft(3, '0')}'; // Format with leading zeros
      }

      setState(() {
        _ahIdController.text = newAhId; // Set the new ID in the text controller
      });
    } catch (e) {
      print('Error generating AH ID: $e');
    }
  }

  bool _validateInputs() {
    // Validate Name
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(_nameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be characters only')),
      );
      return false;
    }

    // Validate Address (No digits compulsion now)
    if (!RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9\s.,()/\-]+$').hasMatch(_addressController.text)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Address must contain at least one letter and may include digits, spaces, commas, periods, parentheses, hyphens, and slashes.')),
  );
  return false;
}

    // Validate Phone Number
    if (!RegExp(r'^\d{10}$').hasMatch(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be a 10-digit number')),
      );
      return false;
    }

    // Validate Email
    if (!_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }

    // Validate Password
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long')),
      );
      return false;
    }

    // Validate Taluka
    if (selectedTaluka == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Taluka')),
      );
      return false;
    }

    return true;
  }

  Future<void> _createAnimalHusbandaryAccount() async {
    if (!_validateInputs()) return; // Only proceed if validation passes

    final ahId = _ahIdController.text;
    final name = _nameController.text;
    final phone = _phoneController.text;
    final address = _addressController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // Firebase Authentication Sign Up
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user information in Firestore under 'animal_husbandary'
      await _firestore.collection('animal_husbandary').doc(ahId).set({
        'AH_id': ahId,
        'Name': name,
        'Phone number': phone,
        'Address': address,
        'Email': email,
        'Taluka': selectedTaluka, // Store selected Taluka
      });

      // Store AH_id and email in a separate collection 'reg_ah'
      await _firestore.collection('reg_ah').doc(ahId).set({
        'AH_id': ahId,
        'Email': email,
      });
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalHusbandaryHomePage(id: ahId),
            ),
      );
      // Navigate to the home page
    } catch (e) {
      print('Error adding Animal Husbandary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating Animal Husbandary account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Animal Husbandary Account'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( // Added scroll option
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.blue, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text(
                  'Enter your details:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _ahIdController,
                  decoration: const InputDecoration(labelText: 'Animal Husbandary ID'),
                  readOnly: true, // Make this field read-only
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 20),
                // Taluka dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Taluka',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTaluka,
                  items: _talukas.map((taluka) {
                    return DropdownMenuItem<String>(
                      value: taluka,
                      child: Text(taluka),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTaluka = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true, // Hide the password for security
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createAnimalHusbandaryAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
