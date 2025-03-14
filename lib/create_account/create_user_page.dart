import 'package:cattle_care_app/user/user_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  String? userId; // Variable to store the generated user ID
  String? email; // Variable to store the email
  String? password; // Variable to store the password
  String? selectedTaluka; // Variable to store the selected Taluka

  // Controllers to capture user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<String> _talukas = [
    'Pernem', 'Bardez', 'Bicholim', 'Satari', 'Tiswadi', 
    'Ponda', 'Murmgao', 'Salcete', 'Sanguem', 'Quepem', 
    'Dharbandora', 'Canacona'
  ];

  @override
  void initState() {
    super.initState();
    _generateUserId(); // Generate the user ID when the form is loaded
  }

  // Function to generate the next user ID
  Future<void> _generateUserId() async {
    CollectionReference users = FirebaseFirestore.instance.collection('user');

    // Fetch the last document in the collection based on the user ID in descending order
    QuerySnapshot querySnapshot = await users.orderBy('User_id', descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      String lastUserId = querySnapshot.docs.first.get('User_id');
      int nextId = int.parse(lastUserId.split('_')[1]) + 1;
      setState(() {
        userId = 'U_${nextId.toString().padLeft(3, '0')}'; // Format the user ID as U_001, U_002, etc.
      });
    } else {
      setState(() {
        userId = 'U_001';
      });
    }
  }

  // Function to validate inputs
  String? _validateInputs() {
    if (_nameController.text.isEmpty || !_isAlphabetic(_nameController.text)) {
      return 'Name must be a string of characters only.';
    }
    if (_addressController.text.isEmpty || !_isValidAddress(_addressController.text)) {
      return 'Address must contain characters and cannot be only digits.';
    }
    if (_phoneController.text.length != 10 || !_isNumeric(_phoneController.text)) {
      return 'Phone number must be a 10-digit number.';
    }
    if (!_isValidDateOfBirth(_dobController.text)) {
      return 'Date of birth must be in the format DD/MM/YYYY.';
    }
    if (_emailController.text.isEmpty) {
      return 'Email is required.';
    }
    if (_passwordController.text.isEmpty) {
      return 'Password is required.';
    }
    if (selectedTaluka == null) {
      return 'Please select a Taluka.';
    }
    return null;
  }

  bool _isAlphabetic(String value) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(value);
  }

  bool _isValidAddress(String value) {
  return RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9\s.,()/\-]+$').hasMatch(value);
}



  bool _isNumeric(String value) {
    return RegExp(r'^\d+$').hasMatch(value);
  }

  bool _isValidDateOfBirth(String value) {
  // Regular expression to validate date in the format DD/MM/YYYY
  final RegExp dateRegExp = RegExp(
    r'^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/(19[0-9][0-9]|20[0-1][0-9]|2020)$'
  );
  
  // Check if the format matches
  if (!dateRegExp.hasMatch(value)) {
    return false;
  }
  
  // Split the date to get day, month, year
  final parts = value.split('/');
  final day = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[2]);
  
  // Validate the number of days in the month
  if (month == 2) { // February
    if (isLeapYear(year)) {
      return day <= 29; // Leap year
    }
    return day <= 28; // Non-leap year
  } else if (month == 4 || month == 6 || month == 9 || month == 11) {
    return day <= 30; // April, June, September, November
  } else {
    return day <= 31; // January, March, May, July, August, October, December
  }
}

// Helper function to check if a year is a leap year
bool isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}


  // Function to save the user data to Firestore
  Future<void> _createUser() async {
    String? validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    if (userId == null) return; // Ensure user ID is generated

    // Authenticate with email and password
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      email = userCredential.user?.email; // Store the authenticated email

      CollectionReference users = FirebaseFirestore.instance.collection('user');

      // Adding user data to Firestore
      await users.doc(userId).set({
        'User_id': userId,
        'Name': _nameController.text,
        'Phone_number': _phoneController.text,
        'Address': _addressController.text,
        'Date_of_birth': _dobController.text,
        'Email': email, // Store email in Firestore
        'Taluka': selectedTaluka, // Store selected Taluka
      }).then((value) async {
        await _storeRegUserData();

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserHomePage(id: userId!),
            ),
      );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create user: $error')),
        );
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: ${e.message}')),
      );
    }
  }

  // Function to store user registration data
  Future<void> _storeRegUserData() async {
    CollectionReference regUsers = FirebaseFirestore.instance.collection('reg_user');

    // Add user registration data to reg_user collection (without password)
    await regUsers.doc(userId).set({
      'User_id': userId,
      'Email': email,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User Account'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( // Enable scrolling
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
                // Display the autogenerated User ID
                TextField(
                  controller: TextEditingController(text: userId ?? 'Generating...'),
                  decoration: const InputDecoration(labelText: 'User ID'),
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
                  keyboardType: TextInputType.phone,
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
                ),
                const SizedBox(height: 20),
                // Password field
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true, // Mask the password
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createUser, // Save the data and navigate to user home
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
