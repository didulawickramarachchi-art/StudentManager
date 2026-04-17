import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageStudentScreen extends StatefulWidget{
  const ManageStudentScreen({super.key});

  @override 

  State<ManageStudentScreen> createState()=>_ManageStudentScreen();
}

class _ManageStudentScreen extends State<ManageStudentScreen>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user's email
    final userEmail = _auth.currentUser?.email ?? "Guest User";

    return Scaffold(
      backgroundColor: Colors.white, // Choose a suitable background
      appBar: AppBar(
        leading: Image.asset("assets/images/logo.png",),
        backgroundColor: const Color.fromARGB(255, 255, 180, 115),
        
      ));
}

}