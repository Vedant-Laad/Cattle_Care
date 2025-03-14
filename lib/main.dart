import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'create_account_selection_page.dart';
import 'create_account/create_user_page.dart';
import 'create_account/create_owner_page.dart';
import 'create_account/create_ngo_page.dart';
import 'create_account/create_animal_husbandary_page.dart';
import 'animal_husbandary/animal_husbandary_homepage.dart';
import 'ngo/ngo_home_page.dart';
import 'owner/owner_home_page.dart';
import 'user/user_home_page.dart';

void main() async {
  if(kIsWeb)
  {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options:const FirebaseOptions(apiKey: "AIzaSyC9vJtoPTq4ZM-nkzLQbnBmIAUX4f7TLYk",
  authDomain: "cattlecare-1bd43.firebaseapp.com",
  projectId: "cattlecare-1bd43",
  storageBucket: "cattlecare-1bd43.appspot.com",
  messagingSenderId: "1053952891238",
  appId: "1:1053952891238:web:17c2d95fee2b38f547d0a7",
  measurementId: "G-SBQ2ZH4ZKY"),);
  }
  else{
    await Firebase.initializeApp();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,//**
      title: 'Cattle Care',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        //'/create_account': (context) => CreateAccountSelectionPage(),
        '/create_user': (context) => const CreateUserPage(),
        '/create_owner': (context) =>  const CreateOwnerPage(),
        '/create_ngo': (context) => const CreateNgoPage(),
        '/create_animal_husbandary': (context) => const CreateAnimalHusbandaryPage(),
        '/ah_home':(context)=> const AnimalHusbandaryHomePage(id:""),
        '/ngo_home':(context)=>const NGOHomePage(id:""),
        '/owner_home':(context)=>const OwnerHomePage(id:""),
        '/user_home':(context)=>const UserHomePage(id:""),
        '/create_account_selection': (context) => const CreateAccountSelectionPage(),
      },
    );
  }
}