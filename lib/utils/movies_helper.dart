import 'package:flutter/material.dart';
import 'package:netflix_clone/services/api.dart';
import 'package:netflix_clone/widgets/bottom_modal.dart';
import 'package:netflix_clone/utils/storage_helper.dart';

mixin MoviesHelper<T extends StatefulWidget> on State<T> {
  final ApiService apiService = ApiService();
  List<dynamic> favoriteMovies = [];
  List<dynamic> likedMovies = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteMovies();
    loadLikedMovies();
    fetchMovies();
  }

  Future<void> fetchMovies() async {}

  Future<void> loadFavoriteMovies() async {
    final loadedMovies = await StorageHelper.loadFavoriteMovies();
    setState(() {
      favoriteMovies = loadedMovies;
    });
  }

  Future<void> loadLikedMovies() async {
    final loadedMovies = await StorageHelper.loadLikedMovies();
    setState(() {
      likedMovies = loadedMovies;
    });
  }

  void addToFavorite(dynamic movie) {
    setState(() {
      int movieId = movie['id'];
      bool isFavorite =
          favoriteMovies.any((favMovie) => favMovie['id'] == movieId);
      if (isFavorite) {
        favoriteMovies.removeWhere((favMovie) => favMovie['id'] == movieId);
      } else {
        favoriteMovies.add(movie);
      }

      StorageHelper.saveFavoriteMovies(favoriteMovies);
    });
  }

  void addToLiked(dynamic movie) {
    setState(() {
      int movieId = movie['id'];
      bool isLiked =
          likedMovies.any((likedMovie) => likedMovie['id'] == movieId);
      if (isLiked) {
        likedMovies.removeWhere((likedMovie) => likedMovie['id'] == movieId);
      } else {
        likedMovies.add(movie);
      }

      StorageHelper.saveLikedMovies(likedMovies);
    });
  }

  void showMovieDetails(BuildContext context, dynamic movieData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomModal(
          movie: movieData,
          onAddToFavorite: addToFavorite,
          favoriteMovies: favoriteMovies,
        );
      },
    );
  }
}
