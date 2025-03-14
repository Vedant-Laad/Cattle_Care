import 'package:cattle_care_app/owner/owner_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateOwnerPage extends StatefulWidget {
  const CreateOwnerPage({super.key});

  @override
  _CreateOwnerPageState createState() => _CreateOwnerPageState();
}

class _CreateOwnerPageState extends State<CreateOwnerPage> {
  String ownerId = 'Loading...';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? selectedTaluka; // Variable to store selected Taluka
  final List<String> _talukas = [
    'Pernem', 'Bardez', 'Bicholim', 'Satari', 'Tiswadi', 
    'Ponda', 'Murmgao', 'Salcete', 'Sanguem', 'Quepem', 
    'Dharbandora', 'Canacona'
  ];

  @override
  void initState() {
    super.initState();
    _generateOwnerId();
  }

  Future<void> _generateOwnerId() async {
    CollectionReference owners = FirebaseFirestore.instance.collection('owner');
    QuerySnapshot querySnapshot = await owners.orderBy('Owner_id', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String lastOwnerId = querySnapshot.docs.first['Owner_id'];
      int lastIdNumber = int.parse(lastOwnerId.split('_')[1]);
      String newOwnerId = 'O_${(lastIdNumber + 1).toString().padLeft(3, '0')}';

      setState(() {
        ownerId = newOwnerId;
      });
    } else {
      setState(() {
        ownerId = 'O_001';
      });
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

    // Validate Address
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

    // Validate Date of Birth
    if (!RegExp(r'^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/(19[0-9]{2}|20[0-5][0-9]|206[0-9])$').hasMatch(_dobController.text)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('DOB must be in DD/MM/YYYY format')),
  );
  return false;
}

    // Validate Email
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }

    // Validate Password
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
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

  Future<void> _createOwner() async {
    if (!_validateInputs()) return; // Only proceed if validation passes

    // Authenticate user with Firebase
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save owner details to Firestore
      CollectionReference owners = FirebaseFirestore.instance.collection('owner');
      await owners.doc(ownerId).set({
        'Owner_id': ownerId,
        'Name': _nameController.text,
        'Phone Number': _phoneController.text,
        'Address': _addressController.text,
        'DOB': _dobController.text,
        'Taluka': selectedTaluka, // Store selected Taluka
        'Email': _emailController.text, // Save email ID
      });

      // Save registration data to reg_owner collection
      CollectionReference regOwners = FirebaseFirestore.instance.collection('reg_owner');
      await regOwners.doc(ownerId).set({
        'Owner_id': ownerId,
        'Email': _emailController.text,
      });

      // Navigate to the owner home page after successful creation
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OwnerHomePage(id: ownerId),
            ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create owner: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Owner Account'),
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
                // Read-only Owner ID field
                TextField(
                  controller: TextEditingController(text: ownerId),
                  decoration: const InputDecoration(labelText: 'Owner ID'),
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
                // Date of Birth field
                TextField(
                  controller: _dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth (DD/MM/YYYY)'),
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
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a Taluka.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Email field
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email ID'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createOwner,
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
