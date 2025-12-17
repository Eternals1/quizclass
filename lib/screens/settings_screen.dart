import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Profil")),
      body: FutureBuilder<DocumentSnapshot>(
        // Mengambil data nama dari Firestore agar lebih akurat
        future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          String name = "Memuat...";
          if (snapshot.hasData && snapshot.data!.exists) {
            name = snapshot.data!['name'];
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 20),
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  user?.email ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Versi Aplikasi"),
                trailing: const Text("1.0.0"),
              ),
              const Divider(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Keluar dari Akun"),
                onPressed: () async {
                  await AuthService().logout();
                  Navigator.pop(context); // Kembali ke HomeScreen, lalu StreamBuilder akan otomatis ke Login
                },
              ),
            ],
          );
        },
      ),
    );
  }
}