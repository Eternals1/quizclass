import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_class_app/screens/settings_screen.dart';
import '../services/database_service.dart';
import 'class_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Warna background abu-abu sangat muda
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2575FC), // Senada dengan Login
        title: const Text(
          "Kelas Saya",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Header Selamat Datang Sederhana
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Halo,",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  user?.email?.split('@')[0] ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Daftar Kelas
          Expanded(
            child: StreamBuilder(
              stream: DatabaseService().getMyClasses(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.class_outlined, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Belum ada kelas. Yuk buat atau gabung!",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 15, bottom: 80),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index];
                    return _buildClassCard(context, data, user);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionSheet(context, user.uid),
        backgroundColor: const Color(0xFF6A11CB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Kelas", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Widget Kartu Kelas yang Dipercantik
  Widget _buildClassCard(BuildContext context, dynamic data, User user) {
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
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.book, color: Colors.white),
          ),
          title: Text(
            data['className'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vpn_key_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(data['classCode'], style: const TextStyle(color: Colors.blueGrey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(data['teacherName'], style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetailScreen(
                  classId: data['classCode'],
                  className: data['className'],
                  currentUserId: user.uid,
                  teacherId: data['teacherId'],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
               Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
              ),
              const SizedBox(height: 25),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.create, color: Colors.white)),
                title: const Text("Buat Kelas Baru", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Anda akan menjadi Guru"),
                onTap: () {
                  Navigator.pop(context);
                  _showForm(context, "Buat", (val) => DatabaseService().createClass(val, uid, "Guru Saya"));
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.purpleAccent, child: Icon(Icons.group_add, color: Colors.white)),
                title: const Text("Gabung Kelas", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Masuk sebagai Murid"),
                onTap: () {
                  Navigator.pop(context);
                  _showForm(context, "Gabung", (val) => DatabaseService().joinClass(val, uid));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, String type, Function(String) action) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("$type Kelas", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: type == "Buat" ? "Contoh: Biologi A" : "Masukkan 6 digit kode",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2575FC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                action(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(type, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}