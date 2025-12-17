import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ManageQuestionsScreen extends StatefulWidget {
  final String classId;
  final String quizId;
  final String quizTitle;

  const ManageQuestionsScreen({
    super.key,
    required this.classId,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2575FC),
        title: Text(
          widget.quizTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2575FC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text(
              "Daftar soal yang telah Anda buat untuk kuis ini.",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          
          Expanded(
            child: StreamBuilder(
              stream: DatabaseService().getQuestions(widget.classId, widget.quizId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var questions = snapshot.data!.docs;

                if (questions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.post_add, size: 80, color: Colors.grey[300]),
                        const Text("Belum ada soal. Tambahkan soal pertama!",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var q = questions[index];
                    return _buildQuestionCard(context, q, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuestionForm(context),
        backgroundColor: const Color(0xFF6A11CB),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Soal"),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, dynamic q, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2575FC),
          child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          q['question'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Skor: ${q['score']} | Kunci: ${q['correct']}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (q['detail'].toString().isNotEmpty) ...[
                  const Text("Detail/Cerita:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(q['detail']),
                  const Divider(),
                ],
                const Text("Opsi Jawaban:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                _optionText("A", q['options'][0], q['correct'] == "A"),
                _optionText("B", q['options'][1], q['correct'] == "B"),
                _optionText("C", q['options'][2], q['correct'] == "C"),
                _optionText("D", q['options'][3], q['correct'] == "D"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _optionText(String code, String text, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$code. ", style: TextStyle(fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal, color: isCorrect ? Colors.green : Colors.black)),
          Expanded(child: Text(text, style: TextStyle(color: isCorrect ? Colors.green : Colors.black87))),
          if (isCorrect) const Icon(Icons.check_circle, color: Colors.green, size: 16),
        ],
      ),
    );
  }

  void _showAddQuestionForm(BuildContext context) {
    final detailCtrl = TextEditingController();
    final questionCtrl = TextEditingController();
    final optACtrl = TextEditingController();
    final optBCtrl = TextEditingController();
    final optCCtrl = TextEditingController();
    final optDCtrl = TextEditingController();
    final scoreCtrl = TextEditingController();
    String selectedCorrect = 'A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder( // Agar dropdown bisa terupdate di dalam sheet
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text("Tambah Soal Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _formField(detailCtrl, "Cerita/Detail (Opsional)", Icons.notes),
                _formField(questionCtrl, "Pertanyaan", Icons.help_outline),
                Row(
                  children: [
                    Expanded(child: _formField(optACtrl, "Opsi A", Icons.radio_button_unchecked)),
                    const SizedBox(width: 10),
                    Expanded(child: _formField(optBCtrl, "Opsi B", Icons.radio_button_unchecked)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _formField(optCCtrl, "Opsi C", Icons.radio_button_unchecked)),
                    const SizedBox(width: 10),
                    Expanded(child: _formField(optDCtrl, "Opsi D", Icons.radio_button_unchecked)),
                  ],
                ),
                _formField(scoreCtrl, "Skor", Icons.star_border, isNumber: true),
                
                DropdownButtonFormField<String>(
                  value: selectedCorrect,
                  decoration: InputDecoration(
                    labelText: "Jawaban Benar",
                    prefixIcon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  items: ['A', 'B', 'C', 'D'].map((e) => DropdownMenuItem(value: e, child: Text("Opsi $e"))).toList(),
                  onChanged: (val) => setSheetState(() => selectedCorrect = val!),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2575FC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      if(questionCtrl.text.isEmpty) return;
                      DatabaseService().addQuestion(widget.classId, widget.quizId, {
                        'detail': detailCtrl.text,
                        'question': questionCtrl.text,
                        'options': [optACtrl.text, optBCtrl.text, optCCtrl.text, optDCtrl.text],
                        'correct': selectedCorrect,
                        'score': int.tryParse(scoreCtrl.text) ?? 0,
                      });
                      Navigator.pop(context);
                    },
                    child: const Text("SIMPAN SOAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6A11CB)),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}