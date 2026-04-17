import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:studentmanger/screens/login_screen.dart'; // Import login screen for logout navigation

class dashboard_screen extends StatefulWidget {
  const dashboard_screen({super.key});

  @override
  State<dashboard_screen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<dashboard_screen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth

  // Function to handle user logout
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      // Navigate back to the login screen after successful logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const login_screen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logged out successfully."),
          backgroundColor: Colors.blueGrey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: $e"),
          backgroundColor: Colors.red,
        ),
      );
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user's email
    final userEmail = _auth.currentUser?.email ?? "Guest User";

    return Scaffold(
      backgroundColor: Colors.white, // Choose a suitable background
      appBar: AppBar(
        leading: Image.asset("assets/images/logo.png",),
        backgroundColor: const Color.fromARGB(255, 255, 180, 115),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard,
              size: 100,
              color: Color.fromARGB(255, 255, 190, 100),
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome, $userEmail!",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "This is your student manager dashboard.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // You can add more dashboard features here, e.g., buttons to view students, add new entries, etc.
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feature coming soon!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Manage Students",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            SizedBox(
              height:10
            ),

             ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feature coming soon!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Mark Atendance",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(
              height:10
            ),

            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Feature coming soon!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "View all Students",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
