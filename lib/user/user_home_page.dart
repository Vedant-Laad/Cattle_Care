import 'package:flutter/material.dart';
import 'owner_details_page.dart'; // Import the Owner Details page
import 'package:cattle_care_app/animal_husbandary/ngos_registered_page.dart'; // Import the NGO Registered page

class UserHomePage extends StatelessWidget {
  final String id;
  const UserHomePage({super.key, required this.id});

  // Function to handle sign-out logic
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
            onPressed: () {
              // If you're using Firebase Auth, call this:
              // await FirebaseAuth.instance.signOut();

              // Navigate to the login screen and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
    // Determine the screen width
    final isMobile = MediaQuery.of(context).size.width < 600; // Mobile if width is less than 600

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home Page'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Prevent back button from appearing
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon tap
              // For example, navigate to a notifications page
              // Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Call the sign-out method and redirect to the login page
              _signOut(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Added scroll option
        child: Padding(
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
                  // Button for scanning QR code
                  Text('Logged in as: $id'), // Display the id here or use it to fetch data
                  const SizedBox(height: 10),
                  SizedBox(
                    width: isMobile ? double.infinity : MediaQuery.of(context).size.width / 2 - 10, // Full width on mobile, half on laptop
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OwnerDetailsPage(id: id,)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color
                        foregroundColor: Colors.black, // Text color
                        minimumSize: const Size(double.infinity, 80), // Increased height for better breadth
                      ),
                      child: const Text(
                        'Scan QR Code',
                        style: TextStyle(fontSize: 20), // Increased font size and bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Add space between buttons
                  
                  // Button for NGO Registered page
                  SizedBox(
                    width: isMobile ? double.infinity : MediaQuery.of(context).size.width - 40, // Full width on mobile, half on laptop
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NGOsRegisteredPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color
                        foregroundColor: Colors.black, // Text color
                        minimumSize: const Size(double.infinity, 80), // Increased height for better breadth
                      ),
                      child: const Text(
                        'NGO Registered Page',
                        style: TextStyle(fontSize: 20,), // Increased font size and bold
                      ),
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
