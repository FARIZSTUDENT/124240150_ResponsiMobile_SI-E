import 'package:flutter/material.dart';
import 'package:spaceflight_app/models/recipe.dart';

import '../services/api_service.dart';
import '../services/favorite_service.dart';

class DetailPage extends StatefulWidget {
  final Recipe initial;
  const DetailPage({super.key, required this.initial});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Recipe> _future;

  @override
  void initState() {
    super.initState();
    // Detail diakses berdasarkan id (sesuai soal).
    _future = ApiService.fetchDetail(widget.initial.type, widget.initial.id);
  }

  /// Toggle favorit lalu tampilkan snackbar sesuai hasilnya.
  Future<void> _toggleFav(Recipe a) async {
    final added = await FavoriteService.instance.toggle(a);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // hindari snackbar menumpuk bila diklik cepat
      ..showSnackBar(SnackBar(
        content:
            Text(added ? 'Ditambahkan ke favorite' : 'Dihapus dari favorite'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        // Pakai data API bila ada; kalau belum/gagal pakai data dari list.
        final a = snap.data ?? widget.initial;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail'),
            actions: [
              // ListenableBuilder: ikon hati berubah (kosong/merah) otomatis
              // setiap FavoriteService memanggil notifyListeners().
              ListenableBuilder(
                listenable: FavoriteService.instance,
                builder: (_, __) {
                  final fav = FavoriteService.instance.isFavorite(a);
                  return IconButton(
                    tooltip: 'Favorite',
                    icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                        color: fav ? Colors.red : Colors.white),
                    onPressed: () => _toggleFav(a),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Garis loading tipis di atas saat detail masih diambil.
              if (loading) const LinearProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- Gambar (wajib) rasio 16:9, ada penanganan error ----
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: a.image.isEmpty
                            ? const Center(
                                child:
                                    Icon(Icons.broken_image_outlined, size: 48))
                            : Image.network(
                                a.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        size: 48)),
                              ),
                      ),
                      // bottom 96 = ruang agar teks tidak tertutup tombol FAB
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul (wajib)
                            Text(a.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            // Author (wajib)
                            Text(a.cuisine,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            // Rating
                            Text(a.rating,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                            const SizedBox(height: 16),
                            // Instruksi
                            Text(a.instructions,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
