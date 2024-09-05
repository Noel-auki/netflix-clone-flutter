import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageHelper {
  static Future<void> saveFavoriteMovies(List<dynamic> favoriteMovies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteMoviesJson =
        favoriteMovies.map((movie) => jsonEncode(movie)).toList();
    await prefs.setStringList('favoriteMovies', favoriteMoviesJson);
  }

  static Future<List<dynamic>> loadFavoriteMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteMoviesJson = prefs.getStringList('favoriteMovies');

    if (favoriteMoviesJson == null) {
      return [];
    }

    return favoriteMoviesJson.map((movie) => jsonDecode(movie)).toList();
  }

  static Future<void> saveLikedMovies(List<dynamic> likedMovies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> likedMoviesJson =
        likedMovies.map((movie) => jsonEncode(movie)).toList();
    await prefs.setStringList('likedMovies', likedMoviesJson);
  }

  static Future<List<dynamic>> loadLikedMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedMoviesJson = prefs.getStringList('likedMovies');

    if (likedMoviesJson == null) {
      return [];
    }

    return likedMoviesJson.map((movie) => jsonDecode(movie)).toList();
  }
}
