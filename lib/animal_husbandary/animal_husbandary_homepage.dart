import 'package:cattle_care_app/cattle_seizure/cattle_details_seizure.dart';
import 'package:cattle_care_app/cattle_seizure/view_seizure_details.dart';
import 'package:flutter/material.dart';
import 'view_owner_cattle_page.dart';
import 'fines_issued_page.dart';
import 'queries_page.dart';
import 'ngos_registered_page.dart';
import 'show_complaints_page.dart'; // Import the ShowComplaintsPage
import 'package:cattle_care_app/login_page.dart'; // Assume this is the login page


class AnimalHusbandaryHomePage extends StatelessWidget {
  final String id;
  const AnimalHusbandaryHomePage({super.key,required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Husbandary Home Page'),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel',style: TextStyle(color: Colors.black),),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: const Text('Yes, Sign-Out',style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Logged in as: $id'), // Display the id here or use it to fetch data
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ViewOwnerCattlePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('View Owner and Cattle Details',style: TextStyle(fontSize: 20,),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FinesIssuedPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('Fines Issued',style: TextStyle(fontSize: 20,),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QueriesPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('Queries',style: TextStyle(fontSize: 20,),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const NGOsRegisteredPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('NGOs Registered',style: TextStyle(fontSize: 20,),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ShowComplaintsPage(id:id)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('Show Complaints',style: TextStyle(fontSize: 20,),),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                CattleSeizureAllowancePage(id:id)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('Cattle Seizure',style: TextStyle(fontSize: 20,),),
                    ),
                    const SizedBox(height: 10),
                    // New button for View Seizure Details
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ViewSeizureDetailsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 80),
                      ),
                      child: const Text('View Seizure Details',style: TextStyle(fontSize: 20,),),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
