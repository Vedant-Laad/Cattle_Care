import 'package:cattle_care_app/ngo/ngo_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateNgoPage extends StatefulWidget {
  const CreateNgoPage({super.key});

  @override
  _CreateNgoPageState createState() => _CreateNgoPageState();
}

class _CreateNgoPageState extends State<CreateNgoPage> {
  final TextEditingController _ngoIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? selectedTaluka; // Variable to store selected Taluka
  final List<String> _talukas = [
    'Pernem', 'Bardez', 'Bicholim', 'Satari', 'Tiswadi', 
    'Ponda', 'Murmgao', 'Salcete', 'Sanguem', 'Quepem', 
    'Dharbandora', 'Canacona'
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _generateNgoId();
  }

  Future<void> _generateNgoId() async {
    try {
      final QuerySnapshot ngoSnapshot = await _firestore
          .collection('ngo')
          .orderBy('NGO_id', descending: true)
          .limit(1)
          .get();

      if (ngoSnapshot.docs.isNotEmpty) {
        final lastNgoId = ngoSnapshot.docs.first['NGO_id'];
        final int newIdNumber = int.parse(lastNgoId.split('_')[1]) + 1;
        _ngoIdController.text = 'NGO_${newIdNumber.toString().padLeft(3, '0')}';
      } else {
        _ngoIdController.text = 'NGO_001';
      }
    } catch (e) {
      print('Error generating NGO ID: $e');
      _ngoIdController.text = 'NGO_001';
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
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
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

  Future<void> _createNgoAccount() async {
    if (!_validateInputs()) return; // Only proceed if validation passes

    final String ngoId = _ngoIdController.text;
    final String name = _nameController.text;
    final String phone = _phoneController.text;
    final String address = _addressController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    try {
      // Create user authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add NGO details to Firestore with ngoId as the document ID
      await _firestore.collection('ngo').doc(ngoId).set({
        'NGO_id': ngoId,        // Using NGO_id as the document ID
        'Name': name,
        'Phone number': phone,
        'Address': address,
        'Email': email,
        'Taluka': selectedTaluka, // Store selected Taluka
      });

      // Register NGO in the reg_ngo collection
      await _firestore.collection('reg_ngo').doc(ngoId).set({
        'NGO_id': ngoId,
        'Email': email,
      });

      // Navigate to NGO home page
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NGOHomePage(id: ngoId),
            ),
      );
    } catch (e) {
      print('Error adding NGO: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating NGO account: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create NGO Account'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
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
                // Read-only NGO ID field
                TextField(
                  controller: _ngoIdController,
                  decoration: const InputDecoration(labelText: 'NGO ID'),
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                // Name field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 20),
                // Address field
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 20),
                // Phone Number field
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
                ),
                const SizedBox(height: 20),
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Hide password input
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createNgoAccount,
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
