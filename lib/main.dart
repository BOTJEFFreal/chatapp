import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Screens/Chatroom.dart';
import 'Screens/HomeScreen.dart';
import 'Screens/LoginScreen.dart';

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class Authenticate extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    if(_auth.currentUser != null){
      return HomeScreen();
    }
    else{
      return LoginScreen();
    }
  }
}


