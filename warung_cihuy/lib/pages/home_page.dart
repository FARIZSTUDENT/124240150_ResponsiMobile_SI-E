import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import 'list_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String username; // diterima dari halaman login / SplashGate
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Muat favorit milik user ini begitu masuk Home.
    FavoriteService.instance.load(widget.username);
  }

  Future<void> _logout() async {
    await AuthService.logout(); // hapus sesi di sharedPreferences
    FavoriteService.instance.clear();
    if (!mounted) return;
    // pushAndRemoveUntil: pindah ke Login & hapus SEMUA halaman
    // sebelumnya dari stack (predicate `(_) => false`).
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hai, ${widget.username}!'), // AppBar tampilkan username
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MenuCard(
            icon: Icons.fork_left_outlined,
            title: 'Menu',
            desc: 'Lihat menu dengan menekan tombol ini',
            onTap: () => _open('recipes', 'Recipe'),
          ),
          const SizedBox(height: 12),
          // Tombol logout di BAWAH pilihan menu (syarat soal).
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: _logout,
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  /// Buka halaman list untuk endpoint [type] dengan judul AppBar [name].
  void _open(String type, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ListPage(type: type, name: name)),
    );
  }
}

/// Kartu menu (ikon + judul + deskripsi) yang bisa diklik.
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      // InkWell = efek ripple saat disentuh + mendeteksi klik.
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.purple, size: 28),
              ),
              const SizedBox(width: 16),
              // Expanded: teks mengisi sisa lebar & turun baris otomatis.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
