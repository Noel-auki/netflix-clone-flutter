import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteMoviesProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  static const _key = 'favorite_movies';
  List<dynamic> _favoriteMovies = [];

  List<dynamic> get favoriteMovies => _favoriteMovies;

  FavoriteMoviesProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    var data = _prefs.getString(_key);
    if (data != null) {
      _favoriteMovies = json.decode(data);
    }
    notifyListeners();
  }

  void toggleFavorite(dynamic movie) {
    final int movieId = movie['id'];
    bool isFavorite =
        _favoriteMovies.any((favMovie) => favMovie['id'] == movieId);
    if (isFavorite) {
      _favoriteMovies.removeWhere((favMovie) => favMovie['id'] == movieId);
    } else {
      _favoriteMovies.add(movie);
    }
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setString(_key, json.encode(_favoriteMovies));
  }
}
