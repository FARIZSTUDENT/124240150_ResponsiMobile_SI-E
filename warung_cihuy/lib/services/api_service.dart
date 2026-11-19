import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recipe.dart';

class ApiService {
  static const _base = 'https://dummyjson.com/recipes';

  /// ?limit=50 -> minta 50 data sekaligus (default API hanya 10).
  static Future<List<Recipe>> fetchList(String type, {int limit = 50}) async {
    final res = await http
        .get(Uri.parse('$_base?limit=$limit'))
        .timeout(const Duration(seconds: 20)); // batas waktu tunggu
    // 200 = sukses. Selain itu lempar Exception -> ditangkap FutureBuilder.
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat data (${res.statusCode})');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>; // String -> Map
    final results = json['recipes'] as List; // array data ada di key 'recipes'
    // Ubah tiap elemen JSON menjadi objek Article.
    return results
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>, type))
        .toList();
  }

  /// Detail diakses berdasarkan id: /v4/{menu}/{id}/  (sesuai soal).
  static Future<Recipe> fetchDetail(String type, int id) async {
    final res = await http
        .get(Uri.parse('$_base/$id'))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat detail (${res.statusCode})');
    }
    // Detail = 1 objek langsung (bukan dibungkus 'results').
    return Recipe.fromJson(jsonDecode(res.body) as Map<String, dynamic>, type);
  }
}
