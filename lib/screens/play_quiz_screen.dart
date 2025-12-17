import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayQuizScreen extends StatefulWidget {
  final String classId, quizId, quizTitle, userId;
  const PlayQuizScreen({
    super.key, 
    required this.classId, 
    required this.quizId, 
    required this.quizTitle, 
    required this.userId
  });

  @override
  State<PlayQuizScreen> createState() => _PlayQuizScreenState();
}

class _PlayQuizScreenState extends State<PlayQuizScreen> {
  int currentQuestionIndex = 0;
  int totalScore = 0;
  String? userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // Ambil nama asli user untuk disimpan di skor
  void _fetchUserName() async {
    var doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      setState(() {
        userName = doc['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2575FC),
        title: Text(widget.quizTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: DatabaseService().getQuestions(widget.classId, widget.quizId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var questions = snapshot.data!.docs;
          
          if (questions.isEmpty) {
            return const Center(child: Text("Kuis ini belum memiliki soal."));
          }

          if (currentQuestionIndex >= questions.length) {
            return _buildResult();
          }

          var q = questions[currentQuestionIndex];
          List options = q['options'];

          return Column(
            children: [
              // Progress Bar Modern
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.white,
                color: Colors.orangeAccent,
                minHeight: 10,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Soal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2575FC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Soal ${currentQuestionIndex + 1} dari ${questions.length}",
                              style: const TextStyle(color: Color(0xFF2575FC), fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text("Poin: ${q['score']}", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Card Detail Soal (Cerita)
                      if (q['detail'] != "") ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Text(
                            q['detail'],
                            style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Pertanyaan Utama
                      Text(
                        q['question'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 30),

                      // Daftar Pilihan Jawaban
                      ...List.generate(4, (index) {
                        String label = String.fromCharCode(65 + index); // A, B, C, D
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: InkWell(
                            onTap: () {
                              if (label == q['correct']) {
                                totalScore += (q['score'] as int);
                              }
                              setState(() { currentQuestionIndex++; });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFF6A11CB).withOpacity(0.1),
                                    child: Text(label, style: const TextStyle(color: Color(0xFF6A11CB), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      options[index],
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 120, color: Colors.orangeAccent),
          const SizedBox(height: 20),
          const Text(
            "Keren! Kuis Selesai",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("Skor Akhir Kamu:", style: TextStyle(color: Colors.grey, fontSize: 16)),
          Text(
            "$totalScore",
            style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF2575FC)),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () async {
                await DatabaseService().saveQuizScore(
                  widget.classId, 
                  widget.quizId, 
                  widget.userId, 
                  userName ?? "Murid", 
                  totalScore
                );
                Navigator.pop(context);
              },
              child: const Text("SIMPAN & KELUAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}