import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studentmanger/screens/dashboard_screen.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedClass;
  DateTime selectedDate = DateTime.now();

  Map<String, bool> attendanceMap = {};
  List<String> classList = [];

  bool isLoadingAttendance = false;

  final Color bgColor = const Color(0xFFFFF8F2);
  final Color primaryColor = const Color(0xFFB77952);

  Future<void> loadClasses() async {
    final snapshot = await _firestore.collection('students').get();

    final classes = snapshot.docs
        .map((doc) => doc['class'] as String)
        .toSet()
        .toList();

    setState(() {
      classList = classes;
    });
  }

  Future<List<QueryDocumentSnapshot>> getStudents() async {
    final snapshot = await _firestore
        .collection('students')
        .where('class', isEqualTo: selectedClass)
        .get();

    return snapshot.docs;
  }

  Future<void> loadAttendance() async {
    if (selectedClass == null) return;

    setState(() {
      isLoadingAttendance = true;
    });

    try {
      String dateId = selectedDate.toString().split(' ')[0];
      String docId = "${selectedClass}_$dateId";

      final doc =
          await _firestore.collection('attendance').doc(docId).get();

      if (doc.exists) {
        final data = doc.data()!;

        Map<String, bool> loadedAttendance = {};

        data.forEach((key, value) {
          if (key != 'class' && key != 'date') {
            loadedAttendance[key] = value == true;
          }
        });

        setState(() {
          attendanceMap = loadedAttendance;
        });
      } else {
        setState(() {
          attendanceMap.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading attendance: $e")),
      );
    } finally {
      setState(() {
        isLoadingAttendance = false;
      });
    }
  }

  Future<void> saveAttendance() async {
    if (selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a class")),
      );
      return;
    }

    try {
      String dateId = selectedDate.toString().split(' ')[0];
      String docId = "${selectedClass}_$dateId";

      final studentsSnapshot = await _firestore
          .collection('students')
          .where('class', isEqualTo: selectedClass)
          .get();

      Map<String, dynamic> finalAttendanceData = {
        'class': selectedClass,
        'date': dateId,
      };

      for (var student in studentsSnapshot.docs) {
        String studentId = student.id;
        finalAttendanceData[studentId] =
            attendanceMap[studentId] ?? false;
      }

      await _firestore
          .collection('attendance')
          .doc(docId)
          .set(finalAttendanceData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving attendance: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadClasses();
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
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const dashboard_screen(),
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
                          "Mark Attendance",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(
                        Icons.fact_check_rounded,
                        color: Colors.brown,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Track Student Attendance",
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

            const SizedBox(height: 16),

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // CLASS DROPDOWN
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.brown.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(
                          border: InputBorder.none,
                        ),
                        hint:
                            const Text("Select Class"),
                        value: selectedClass,
                        items: classList.map((cls) {
                          return DropdownMenuItem(
                            value: cls,
                            child: Text(cls),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          setState(() {
                            selectedClass = value;
                            attendanceMap.clear();
                          });

                          await loadAttendance();
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // DATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryColor,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                        ),
                        label: Text(
                          selectedDate
                              .toString()
                              .split(' ')[0],
                          style:
                              const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () async {
                          DateTime? picked =
                              await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDate,
                            firstDate:
                                DateTime(2020),
                            lastDate:
                                DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate =
                                  picked;
                            });

                            await loadAttendance();
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // STUDENT LIST
                    Expanded(
                      child: selectedClass == null
                          ? const Center(
                              child: Text(
                                "Please select a class",
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            )
                          : isLoadingAttendance
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(),
                                )
                              : FutureBuilder<
                                  List<
                                      QueryDocumentSnapshot>>(
                                  future:
                                      getStudents(),
                                  builder:
                                      (context,
                                          snapshot) {
                                    if (snapshot
                                            .connectionState ==
                                        ConnectionState
                                            .waiting) {
                                      return const Center(
                                        child:
                                            CircularProgressIndicator(),
                                      );
                                    }

                                    if (!snapshot
                                            .hasData ||
                                        snapshot
                                            .data!
                                            .isEmpty) {
                                      return const Center(
                                        child: Text(
                                            "No students found"),
                                      );
                                    }

                                    final students =
                                        snapshot
                                            .data!;

                                    return ListView
                                        .builder(
                                      itemCount:
                                          students
                                              .length,
                                      itemBuilder:
                                          (context,
                                              index) {
                                        final student =
                                            students[
                                                index];

                                        String id =
                                            student
                                                .id;
                                        String name =
                                            student[
                                                'name'];

                                        bool isPresent =
                                            attendanceMap[
                                                    id] ??
                                                false;

                                        return Container(
                                          margin:
                                              const EdgeInsets.only(
                                                  bottom:
                                                      12),
                                          padding:
                                              const EdgeInsets.all(
                                                  14),
                                          decoration:
                                              BoxDecoration(
                                            color: Colors
                                                .white,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors
                                                    .brown
                                                    .withOpacity(
                                                        0.07),
                                                blurRadius:
                                                    8,
                                                offset:
                                                    const Offset(
                                                        0,
                                                        4),
                                              ),
                                            ],
                                          ),
                                          child:
                                              CheckboxListTile(
                                            contentPadding:
                                                EdgeInsets.zero,
                                            activeColor:
                                                Colors
                                                    .green,
                                            title:
                                                Text(
                                              name,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize:
                                                    17,
                                              ),
                                            ),
                                            subtitle:
                                                Text(
                                              "ID: $id",
                                            ),
                                            secondary:
                                                CircleAvatar(
                                              backgroundColor:
                                                  isPresent
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                              child:
                                                  Icon(
                                                isPresent
                                                    ? Icons.check
                                                    : Icons.close,
                                                color: Colors
                                                    .white,
                                              ),
                                            ),
                                            value:
                                                isPresent,
                                            onChanged:
                                                (value) {
                                              setState(
                                                  () {
                                                attendanceMap[id] =
                                                    value ??
                                                        false;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                    ),

                    const SizedBox(height: 12),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    18),
                          ),
                        ),
                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Save / Update Attendance",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        onPressed:
                            saveAttendance,
                      ),
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}