import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:studentmanger/screens/start_screen.dart';
import 'firebase_options.dart'; // Import your generated Firebase options

void main() async { // Make main function asynchronous
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp( // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StudentManager());
}
