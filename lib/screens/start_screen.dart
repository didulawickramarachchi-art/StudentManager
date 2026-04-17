import 'package:flutter/material.dart';
import 'package:studentmanger/screens/login_screen.dart';

class StudentManager extends StatelessWidget {
  const StudentManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const login_screen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD18C),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // LOGO
            Image.asset(
              "assets/images/logo.png",
              width: 330,
              
            ),

            const SizedBox(height: 20),

            // TITLE
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 40,
                fontFamily: "Modern",
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 80),

            const CircularProgressIndicator(
              color: Colors.brown,
            ),
          ],
        ),
      ),
    );
  }
}