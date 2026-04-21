import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studentmanger/screens/dashboard_screen.dart';

class ViewAllStudentsScreen extends StatefulWidget {
  const ViewAllStudentsScreen({super.key});

  @override
  State<ViewAllStudentsScreen> createState() => _ViewAllStudentsScreenState();
}

class _ViewAllStudentsScreenState extends State<ViewAllStudentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _searchBy = 'studentId';
  String? _selectedClass;
  List<String> _classList = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final snapshot = await _firestore.collection('students').get();

      final classes = snapshot.docs
          .map((doc) => (doc['class'] ?? '').toString().trim())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();

      classes.sort();

      setState(() {
        _classList = classes;
      });
    } catch (e) {
      debugPrint("Error loading classes: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? "Guest User";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFB473),
                    Color(0xFFFFD18C),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.brown,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const dashboard_screen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 46,
                        width: 46,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Image.asset(
                          "assets/images/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "All Students",
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
                  Row(
                    children: [
                      Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          size: 32,
                          color: Color(0xFF8D5A3B),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Student Directory",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4E342E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Logged in as $userEmail",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _searchBy == 'studentId'
                        ? TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by studentId...',
                              hintStyle: const TextStyle(color: Colors.black45),
                              filled: true,
                              fillColor: const Color(0xFFFFF4EA),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Colors.brown,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: () {
                                        _searchController.clear();
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedClass,
                            decoration: InputDecoration(
                              hintText: 'Select class',
                              filled: true,
                              fillColor: const Color(0xFFFFF4EA),
                              prefixIcon: const Icon(
                                Icons.class_rounded,
                                color: Colors.brown,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _classList.map((cls) {
                              return DropdownMenuItem<String>(
                                value: cls,
                                child: Text(cls),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedClass = value;
                              });
                            },
                          ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          "Search by:",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6D4C41),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Student ID'),
                                selected: _searchBy == 'studentId',
                                selectedColor: const Color(0xFFFFCC9C),
                                backgroundColor: const Color(0xFFFFF4EA),
                                labelStyle: TextStyle(
                                  color: _searchBy == 'studentId'
                                      ? Colors.brown.shade900
                                      : Colors.brown.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: _searchBy == 'studentId'
                                        ? Colors.brown.shade300
                                        : Colors.transparent,
                                  ),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _searchBy = 'studentId';
                                      _selectedClass = null;
                                    });
                                  }
                                },
                              ),
                              ChoiceChip(
                                label: const Text('Class'),
                                selected: _searchBy == 'class',
                                selectedColor: const Color(0xFFFFCC9C),
                                backgroundColor: const Color(0xFFFFF4EA),
                                labelStyle: TextStyle(
                                  color: _searchBy == 'class'
                                      ? Colors.brown.shade900
                                      : Colors.brown.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: _searchBy == 'class'
                                        ? Colors.brown.shade300
                                        : Colors.transparent,
                                  ),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _searchBy = 'class';
                                      _searchController.clear();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Student List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildStudentStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB77952),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 60,
                              color: Colors.brown,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No students found.',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4E342E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final studentData =
                          snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 54,
                                    width: 54,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF1E3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFFB77952),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentData['name'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4E342E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "ID: ${studentData['studentId'] ?? 'N/A'}",
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFE0BF),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      studentData['class'] ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6D4C41),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                Icons.cake_rounded,
                                "Age",
                                "${studentData['age'] ?? 'N/A'}",
                              ),
                              _buildInfoRow(
                                Icons.location_on_rounded,
                                "Address",
                                "${studentData['address'] ?? 'N/A'}",
                              ),
                              _buildInfoRow(
                                Icons.phone_rounded,
                                "Contact",
                                "${studentData['contactNumbers'] ?? 'N/A'}",
                              ),
                              if (studentData['addedBy'] != null)
                                _buildInfoRow(
                                  Icons.person_add_alt_1_rounded,
                                  "Added By",
                                  "${studentData['addedBy']}",
                                ),
                            ],
                          ),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB77952)),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildStudentStream() {
    final CollectionReference studentsRef = _firestore.collection('students');

    if (_searchBy == 'studentId') {
      if (_searchQuery.isEmpty) {
        return studentsRef.snapshots();
      }

      return studentsRef
          .orderBy('studentId')
          .startAt([_searchQuery])
          .endAt(['${_searchQuery}\uf8ff'])
          .snapshots();
    } else {
      if (_selectedClass == null || _selectedClass!.isEmpty) {
        return studentsRef.snapshots();
      }

      return studentsRef
          .where('class', isEqualTo: _selectedClass)
          .snapshots();
    }
  }
}