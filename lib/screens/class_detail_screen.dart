import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'manage_question_screen.dart'; 
import 'play_quiz_screen.dart'; 

class ClassDetailScreen extends StatelessWidget {
  final String classId;
  final String className;
  final String currentUserId;
  final String teacherId;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.currentUserId,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    bool isTeacher = currentUserId == teacherId;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF2575FC),
          title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: isTeacher
              ? [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () => _confirmDelete(context),
                  ),
                ]
              : null,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(child: Text("Kuis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              Tab(child: Text("Partisipan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQuizList(isTeacher),
            _buildParticipantList(),
          ],
        ),
        floatingActionButton: isTeacher
            ? FloatingActionButton.extended(
                onPressed: () => _showAddQuizDialog(context),
                backgroundColor: const Color(0xFF6A11CB),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("Set Kuis Baru", style: TextStyle(color: Colors.white)),
              )
            : null,
      ),
    );
  }

  Widget _buildQuizList(bool isTeacher) {
    return StreamBuilder(
      stream: DatabaseService().getQuizzes(classId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;
        
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[300]),
                const Text("Belum ada kuis di kelas ini.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 15),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var quiz = docs[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2575FC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: Color(0xFF2575FC)),
                ),
                title: Text(quiz['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                subtitle: Text(isTeacher ? "Kelola pertanyaan" : "Klik untuk mulai mengerjakan"),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  if (isTeacher) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ManageQuestionsScreen(classId: classId, quizId: quiz.id, quizTitle: quiz['title'])));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayQuizScreen(classId: classId, quizId: quiz.id, quizTitle: quiz['title'], userId: currentUserId)));
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParticipantList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('classes').doc(classId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List members = snapshot.data!['members'] ?? [];
        if (members.isEmpty) return const Center(child: Text("Belum ada partisipan"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: members.length,
          itemBuilder: (context, index) {
            String memberId = members[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(memberId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox();
                var userData = userSnapshot.data!;
                String name = userData.exists ? userData['name'] : "User Tidak Dikenal";
                String email = userData.exists ? userData['email'] : "-";

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: memberId == teacherId ? Colors.orange : const Color(0xFF6A11CB),
                      child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: memberId == teacherId ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        memberId == teacherId ? "Guru" : "Murid",
                        style: TextStyle(color: memberId == teacherId ? Colors.orange : Colors.blue, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddQuizDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Set Kuis", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Misal: Kuis Mingguan IPA",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2575FC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                DatabaseService().createQuizSet(classId, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Buat", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Kelas?"),
        content: const Text("Semua data kuis dan nilai akan hilang permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('classes').doc(classId).delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}