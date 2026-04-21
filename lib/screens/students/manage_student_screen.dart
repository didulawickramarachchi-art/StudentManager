import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studentmanger/screens/dashboard_screen.dart';

class ManageStudentScreen extends StatefulWidget {
  const ManageStudentScreen({super.key});

  @override
  State<ManageStudentScreen> createState() => _ManageStudentScreenState();
}

class _ManageStudentScreenState extends State<ManageStudentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Color bgColor = const Color(0xFFFFF8F2);
  final Color cardColor = Colors.white;
  final Color primaryColor = const Color(0xFFB77952);

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteStudent(String studentId) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
      _showSnackBar('Student deleted successfully', Colors.green);
    } catch (e) {
      _showSnackBar('Delete failed: $e', Colors.red);
    }
  }

  Future<void> _showStudentDialog({DocumentSnapshot? studentDoc}) async {
    final bool isEdit = studentDoc != null;

    final studentIdController = TextEditingController(
      text: isEdit ? studentDoc['studentId'] ?? '' : '',
    );
    final nameController = TextEditingController(
      text: isEdit ? studentDoc['name'] ?? '' : '',
    );
    final ageController = TextEditingController(
      text: isEdit ? studentDoc['age'].toString() : '',
    );
    final addressController = TextEditingController(
      text: isEdit ? studentDoc['address'] ?? '' : '',
    );
    final contactController = TextEditingController(
      text: isEdit ? studentDoc['contactNumbers'] ?? '' : '',
    );
    final classController = TextEditingController(
      text: isEdit ? studentDoc['class'] ?? '' : '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          isEdit ? "Update Student" : "Add Student",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: studentIdController,
                label: "Student ID",
                enabled: !isEdit,
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: nameController, label: "Name"),
              const SizedBox(height: 12),
              _buildTextField(
                controller: ageController,
                label: "Age",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: addressController,
                label: "Address",
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: contactController,
                label: "Contact Number",
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: classController,
                label: "Course / Class",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () async {
              final studentId = studentIdController.text.trim();
              final name = nameController.text.trim();
              final age = int.tryParse(ageController.text.trim());
              final address = addressController.text.trim();
              final contact = contactController.text.trim();
              final studentClass = classController.text.trim();

              if (studentId.isEmpty ||
                  name.isEmpty ||
                  age == null ||
                  address.isEmpty ||
                  contact.isEmpty ||
                  studentClass.isEmpty) {
                _showSnackBar("Fill all fields", Colors.red);
                return;
              }

              await _firestore.collection('students').doc(studentId).set({
                'studentId': studentId,
                'name': name,
                'age': age,
                'address': address,
                'contactNumbers': contact,
                'class': studentClass,
                'updatedBy': _auth.currentUser?.email ?? '',
                'timestamp': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              Navigator.pop(context);

              _showSnackBar(
                isEdit
                    ? "Student updated successfully"
                    : "Student added successfully",
                Colors.green,
              );
            },
            child: Text(isEdit ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFFFF4EA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String studentId) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Delete Student"),
        content: const Text("Are you sure you want to delete this student?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteStudent(studentId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFB473),
                    Color(0xFFFFD18C),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const dashboard_screen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        "assets/images/logo.png",
                        height: 38,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Manage Students",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(
                        Icons.school_rounded,
                        size: 34,
                        color: Colors.brown,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Add, Edit & Delete Students",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // STUDENT LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('students')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No students found",
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final students = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];

                      final studentId = student['studentId'];
                      final name = student['name'];
                      final age = student['age'].toString();
                      final studentClass = student['class'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1E3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFFB77952),
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4E342E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "ID: $studentId",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "Age: $age  |  Class: $studentClass",
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  _showStudentDialog(
                                studentDoc: student,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _confirmDelete(studentId),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => _showStudentDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Add Student"),
      ),
    );
  }
}