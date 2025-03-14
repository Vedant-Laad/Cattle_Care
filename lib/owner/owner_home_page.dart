import 'package:cattle_care_app/animal_husbandary/ngos_registered_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cattle_care_app/login_page.dart'; // Ensure you have this login page
import 'register_cattle_page.dart'; // Ensure this page exists
import 'cattles_owned_page.dart'; // Ensure this page exists
import 'fines_issued_page.dart'; // Import FinesIssuedPage
import 'show_complaints_page.dart'; // Import ShowComplaintsPage
import 'queries_page.dart'; // Import QueriesPage

class OwnerHomePage extends StatelessWidget {
  final String id;
  const OwnerHomePage({super.key, required this.id});

  Future<void> _signOut(BuildContext context) async {
    // Show confirmation dialog before signing out
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Sign out the user using Firebase Auth
                await FirebaseAuth.instance.signOut();

                // Close the dialog first
                Navigator.of(context).pop();

                // Then navigate to the login page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                // Handle any errors that occur during sign out
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $e')),
                );
              }
            },
            child: const Text(
              'Yes, Sign Out',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Home Page'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Prevents back button from appearing
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon press
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification Icon Pressed')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut(context); // Call the sign-out method
            },
          ),
        ],
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Logged in as: $id'), // Display the id here or use it to fetch data
                  const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterCattlePage(id: id), // Pass id here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 80), // Full-width button
                  ),
                  child: const Text('Register Cattle',style: TextStyle(fontSize: 20,),),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CattlesOwnedPage(id: id), // Pass id here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 80), // Full-width button
                  ),
                  child: const Text('Cattles Owned',style: TextStyle(fontSize: 20,),),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FinesIssuedPage(id: id), // Pass id here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 80), // Full-width button
                  ),
                  child: const Text('Fines Issued',style: TextStyle(fontSize: 20,),), // Button text
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowComplaintsPage(id: id), // Pass id here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 80), // Full-width button
                  ),
                  child: const Text('Show Complaints',style: TextStyle(fontSize: 20,),), // Button text
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QueriesPage(id: id), // Pass id here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 80), // Full-width button
                  ),
                  child: const Text('View Query Replies',style: TextStyle(fontSize: 20,),), // Button text
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NGOsRegisteredPage(), // Pass id here
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Background color
                    foregroundColor: Colors.black, // Text color
                    minimumSize: const Size(double.infinity, 80), // Full-width button
                  ),
                  child: const Text('Registered NGOs',style: TextStyle(fontSize: 20,),), // Button text for NGOs page
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}