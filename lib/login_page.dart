// Modify each home page to accept the ID parameter
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user/user_home_page.dart';
import 'owner/owner_home_page.dart';
import 'ngo/ngo_home_page.dart';
import 'animal_husbandary/animal_husbandary_homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idController = TextEditingController();
  String _selectedRole = 'User';
  final List<String> _roles = ['User', 'Owner', 'NGO', 'Animal Husbandary'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: Image.asset('assets/logo.png'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.blue, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: _roles.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _authenticateUser();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Sign-In'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_account_selection');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Create a new account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _authenticateUser() async {
    try {
      // Authenticate user with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch user ID
      String userId = userCredential.user!.uid;

      // Determine the Firestore collection based on the selected role
      String collection = _getCollectionForRole();

      // Fetch the document matching the entered ID
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(_idController.text.trim())
          .get();

      if (doc.exists) {
        // Check if the email matches
        String storedEmail = doc['Email'] ?? '';
        if (storedEmail == _emailController.text.trim()) {
          // Successful login, navigate to the corresponding home page
          _navigateToHomePage(_idController.text.trim());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email does not match the role ID.')),
          );
        }
      } else {
        // If no matching ID was found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID does not match any record for the selected role.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication error')),
      );
    }
  }

  String _getCollectionForRole() {
    switch (_selectedRole) {
      case 'User':
        return 'reg_user';
      case 'Owner':
        return 'reg_owner';
      case 'NGO':
        return 'reg_ngo';
      case 'Animal Husbandary':
        return 'reg_ah';
      default:
        throw Exception('Invalid role selected.');
    }
  }

  void _navigateToHomePage(String id) {
    switch (_selectedRole) {
      case 'User':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage(id: id)),
        );
        break;
      case 'Owner':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OwnerHomePage(id: id)),
        );
        break;
      case 'NGO':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NGOHomePage(id: id)),
        );
        break;
        
      case 'Animal Husbandary':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimalHusbandaryHomePage(id: id)),
        );
        break;
        
    }
  }
}
