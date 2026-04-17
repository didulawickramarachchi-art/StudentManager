import 'package:flutter/material.dart';
import 'package:studentmanger/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth


class register_screen extends StatefulWidget {
  const register_screen({super.key});

  @override
  State<register_screen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<register_screen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> register() async { // Make register an async function
    String name = nameController.text.trim(); // Trim whitespace
    String email = emailController.text.trim(); // Trim whitespace
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      // Create user with email and password using Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user's display name (optional, but good for personalized experience)
      await userCredential.user?.updateDisplayName(name);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered Successfully!")),
      );

      // Navigate to login screen after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const login_screen(),
        ),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'An error occurred: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      print("Firebase Auth Error: ${e.code} - ${e.message}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
      print("General Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD18C),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LOGO
              Image.asset(
                "assets/images/logo.png",
                width: 180,
              ),

              const SizedBox(height: 10),

              // TITLE
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: "Modern",
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 30),

              // NAME
              buildField("Name", Icons.person, nameController),

              const SizedBox(height: 15),

              // EMAIL
              buildField("Email", Icons.email, emailController),

              const SizedBox(height: 15),

              // PASSWORD
              buildField("Password", Icons.lock, passwordController, obscure: true),

              const SizedBox(height: 15),

              // CONFIRM PASSWORD
              buildField("Confirm Password", Icons.lock_outline, confirmPasswordController, obscure: true),

              const SizedBox(height: 25),

              // REGISTER BUTTON
              ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const login_screen(),
      ),
    );
  },
  child: const Text(
    "Already have an account? Login",
    style: TextStyle(
      color: Colors.brown,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  ),
),
Text("For Admin Contact the Developer",
style: TextStyle(color:Colors.brown),)
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Reusable input field (clean code)
  Widget buildField(String label, IconData icon, TextEditingController controller,
      {bool obscure = false}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}