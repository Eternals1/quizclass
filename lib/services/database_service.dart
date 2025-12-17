import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fungsi generate kode unik 6 digit untuk kelas
  String _generateClassCode() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }

  // BUAT KELAS (Guru)
  Future<void> createClass(
    String className,
    String teacherId,
    String teacherName,
  ) async {
    String classCode = _generateClassCode();
    await _db.collection('classes').doc(classCode).set({
      'className': className,
      'classCode': classCode,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'members': [teacherId], // Pembuat kelas otomatis jadi member
      'createdAt': DateTime.now(),
    });
  }

  // GABUNG KELAS (Murid)
  Future<String?> joinClass(String classCode, String studentId) async {
    DocumentSnapshot doc = await _db.collection('classes').doc(classCode).get();

    if (doc.exists) {
      await _db.collection('classes').doc(classCode).update({
        'members': FieldValue.arrayUnion([studentId]),
      });
      return null; // Berhasil
    } else {
      return "Kode kelas tidak ditemukan!"; // Gagal
    }
  }

  // AMBIL DAFTAR KELAS YANG DIIKUTI USER
  Stream<QuerySnapshot> getMyClasses(String userId) {
    return _db
        .collection('classes')
        .where('members', arrayContains: userId)
        .snapshots();
  }

  // Tambahkan fungsi ini di dalam class DatabaseService

// BUAT SET KUIS BARU
Future<void> createQuizSet(String classId, String quizTitle) async {
  await _db.collection('classes').doc(classId).collection('quizzes').add({
    'title': quizTitle,
    'createdAt': DateTime.now(),
  });
}

// AMBIL DAFTAR KUIS DALAM KELAS
Stream<QuerySnapshot> getQuizzes(String classId) {
  return _db.collection('classes').doc(classId).collection('quizzes')
      .orderBy('createdAt', descending: true)
      .snapshots();
}

// Tambahkan fungsi ini di dalam class DatabaseService

// TAMBAH SOAL KE DALAM KUIS
Future<void> addQuestion(String classId, String quizId, Map<String, dynamic> questionData) async {
  await _db.collection('classes')
      .doc(classId)
      .collection('quizzes')
      .doc(quizId)
      .collection('questions')
      .add(questionData);
}

// AMBIL DAFTAR SOAL
Stream<QuerySnapshot> getQuestions(String classId, String quizId) {
  return _db.collection('classes')
      .doc(classId)
      .collection('quizzes')
      .doc(quizId)
      .collection('questions')
      .snapshots();
}

// Simpan skor murid setelah selesai kuis
Future<void> saveQuizScore(String classId, String quizId, String userId, String userName, int totalScore) async {
  await _db.collection('classes')
      .doc(classId)
      .collection('quizzes')
      .doc(quizId)
      .collection('scores')
      .doc(userId) // Satu user satu dokumen skor per kuis
      .set({
    'userName': userName,
    'score': totalScore,
    'finishedAt': DateTime.now(),
  });
}

}
