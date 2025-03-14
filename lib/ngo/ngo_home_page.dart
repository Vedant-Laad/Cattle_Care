import 'package:cattle_care_app/animal_husbandary/ngos_registered_page.dart';
import 'package:cattle_care_app/ngo/view_cattle_seizure_details.dart';
import 'package:cattle_care_app/ngo/view_registered_cattle_page.dart';
import 'package:flutter/material.dart';
import 'view_owner_cattle_page.dart'; // Import relevant pages
import 'update_cattle_data_page.dart'; // Create this page
import 'animal_husbandaries_data_page.dart'; // Create this page
import 'package:cattle_care_app/ngo/show_complaints_page.dart'; // Import the Show Complaints page
import 'package:cattle_care_app/ngo/fines_issued_page.dart'; // Import the Fines Issued page

class NGOHomePage extends StatelessWidget {
  final String id; // Accept id field

  const NGOHomePage({super.key, required this.id}); // Require id in the constructor

  // Function to show the sign-out confirmation dialog
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out', style: TextStyle(color: Colors.black)),
          content: const Text('Are you sure you want to sign out?',style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                // Sign out logic here
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              child: const Text('Yes',style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Home Page'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false, // Remove the back button
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
              // Show the sign-out confirmation dialog
              _showSignOutDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Added scrollable option
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
                  Text('Logged in as: $id'), // Display the id here or use it to fetch data
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewOwnerCattlePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('View Owner and Cattle Data',style: TextStyle(fontSize: 20,),),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateCattleDataPage(id:id)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('Update Cattle Data',style: TextStyle(fontSize: 20,),),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AnimalHusbandariesDataPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('Data of Animal Husbandaries',style: TextStyle(fontSize: 20,),),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShowComplaintsPage(id: id)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('Show Complaints',style: TextStyle(fontSize: 20,),),
                  ),
                  const SizedBox(height: 10), // New button for View Registered Cattle
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewRegisteredCattlePage(id: id)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('View Registered Cattle',style: TextStyle(fontSize: 20,),),
                  ),
                  const SizedBox(height: 10), // New button for Fines Issued
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FinesIssuedPage(id: id)), // Navigate to Fines Issued page
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('Fines Issued',style: TextStyle(fontSize: 20,),), // Button text
                  ),
                  const SizedBox(height: 10), // New button for View Cattle Seizure Details
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewSeizureDetailsPage(id: id)), // Navigate to View Cattle Seizure page
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('View Cattle Seizure Details',style: TextStyle(fontSize: 20,),), // Button text
                  ),
                  const SizedBox(height: 10), // New button for NGOs Registered
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NGOsRegisteredPage()), // Navigate to NGOs Registered page
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Background color
                      foregroundColor: Colors.black, // Text color
                      minimumSize: const Size(double.infinity, 80), // Full-width button
                    ),
                    child: const Text('View Registered NGOs',style: TextStyle(fontSize: 20,),), // Button text
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
