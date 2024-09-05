import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netflix_clone/services/api.dart';
import 'package:netflix_clone/widgets/BouncingDotsLoader.dart';
import 'package:netflix_clone/widgets/bottom_modal.dart';
import 'package:netflix_clone/widgets/special_movie.dart';
import 'package:netflix_clone/utils/movie_loaders.dart';
import 'package:netflix_clone/widgets/top_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _showTobBar = true;
  late ScrollController controller;
  final ApiService apiService = ApiService();

  List<dynamic> popularAll = [];
  List<dynamic> popularMovies = [];
  List<dynamic> trendingMovies = [];
  List<dynamic> newReleasesMovies = [];
  List<dynamic> popularTVShows = [];
  List<dynamic> trendingTVShows = [];
  List<String> trendingImages = [];
  List<String> trendingGenres = [];
  List<dynamic> favoriteMovies = [];
  List<dynamic> trendingMoviesData = [];
  String _selectedCategory = 'Home';

  dynamic _selectedMovieForWeb;

  Future<void>? _fetchMoviesFuture;

  int _page = 1;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(_scrollListener);

    loadFavoriteMovies().then((loadedMovies) {
      setState(() {
        favoriteMovies = loadedMovies;
      });
    });

    _fetchMoviesFuture = fetchMovies();
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500 && !_isFetching) {
      setState(() {
        _isFetching = true;
      });
      fetchMoreMovies();
    }
  }

  Future<void> fetchMovies() async {
    final fetchedPopularAll = await apiService.fetchTrendingAll(page: _page);
    final fetchedPopularMovies =
        await apiService.fetchPopularMovies(page: _page);
    final fetchedTrendingMovies =
        await apiService.fetchTrendingMovies(page: _page);
    final fetchedNewReleasesMovies =
        await apiService.fetchNewReleasesMovies(page: _page);
    final fetchedPopularTVShows =
        await apiService.fetchPopularTVShows(page: _page);
    final fetchedTrendingTVShows =
        await apiService.fetchTrendingTVShows(page: _page);
    final fetchedGenres = await apiService.fetchGenres();
    final fetchedTrendingImages = fetchedPopularAll.map<String>((item) {
      String imagePath = kIsWeb ? item['backdrop_path'] : item['poster_path'];
      return 'https://image.tmdb.org/t/p/w500$imagePath';
    }).toList();

    final fetchedTrendingGenres = fetchedPopularAll.map<String>((item) {
      final genreIds = item['genre_ids'] as List<dynamic>;
      return genreIds
          .map((id) => fetchedGenres[id] ?? '')
          .where((genre) => genre.isNotEmpty)
          .join(' • ');
    }).toList();

    setState(() {
      popularAll.addAll(fetchedPopularAll);
      popularMovies.addAll(fetchedPopularMovies);
      trendingMovies.addAll(fetchedTrendingMovies);
      newReleasesMovies.addAll(fetchedNewReleasesMovies);
      popularTVShows.addAll(fetchedPopularTVShows);
      trendingTVShows.addAll(fetchedTrendingTVShows);
      trendingImages.addAll(fetchedTrendingImages);
      trendingGenres.addAll(fetchedTrendingGenres);
      trendingMoviesData.addAll(fetchedPopularAll);

      if (kIsWeb) {
        _selectedMovieForWeb =
            fetchedPopularAll.isNotEmpty ? fetchedPopularAll[0] : null;
      }

      _isFetching = false;
      _page++;
    });
  }

  Future<void> fetchMoreMovies() async {
    if (!_isFetching) {
      setState(() {
        _isFetching = true;
      });
      await fetchMovies();
    }
  }

  Future<void> saveFavoriteMovies(List<dynamic> favoriteMovies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteMoviesJson =
        favoriteMovies.map((movie) => jsonEncode(movie)).toList();
    await prefs.setStringList('favoriteMovies', favoriteMoviesJson);
  }

  Future<List<dynamic>> loadFavoriteMovies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteMoviesJson = prefs.getStringList('favoriteMovies');

    if (favoriteMoviesJson == null) {
      return [];
    }

    return favoriteMoviesJson.map((movie) => jsonDecode(movie)).toList();
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

      saveFavoriteMovies(favoriteMovies);
    });
  }

  void _showMovieDetails(dynamic movieData) {
    if (kIsWeb) {
      setState(() {
        _selectedMovieForWeb = movieData;
      });
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _fetchMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: AnimatedLogoLoader());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading movies'));
          } else {
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (trendingImages.isNotEmpty &&
                          trendingGenres.isNotEmpty)
                        SpecialMovie(
                          images: trendingImages,
                          genres: trendingGenres,
                          movies: trendingMoviesData,
                          onAddToMyList: addToFavorite,
                          favoriteMovies: favoriteMovies,
                          selectedMovie: kIsWeb ? _selectedMovieForWeb : null,
                          enableSlideshow: !kIsWeb,
                        ),
                      if (_selectedCategory == 'Home') ...[
                        const SizedBox(height: 10),
                        MovieLoaders.loadPopularAll(
                            popularAll, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadPopularMovies(
                            popularMovies, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadTrendingNow(
                            trendingMovies, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadPopularTVShows(
                            popularTVShows, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadNewReleases(
                            newReleasesMovies, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadTrendingTVShows(
                            trendingTVShows, _showMovieDetails),
                        const SizedBox(height: 10),
                      ] else if (_selectedCategory == 'TV Shows') ...[
                        const SizedBox(height: 10),
                        MovieLoaders.loadPopularTVShows(
                            popularTVShows, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadTrendingTVShows(
                            trendingTVShows, _showMovieDetails),
                        const SizedBox(height: 10),
                      ] else if (_selectedCategory == 'Movies') ...[
                        const SizedBox(height: 10),
                        MovieLoaders.loadPopularMovies(
                            popularMovies, _showMovieDetails),
                        const SizedBox(height: 10),
                        MovieLoaders.loadTrendingNow(
                            trendingMovies, _showMovieDetails),
                        const SizedBox(height: 10),
                      ] else if (_selectedCategory == 'My List') ...[
                        const SizedBox(height: 10),
                        MovieLoaders.loadMyList(
                            favoriteMovies, _showMovieDetails),
                        const SizedBox(height: 10),
                      ]
                    ],
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  top: _showTobBar ? 0 : -kToolbarHeight,
                  left: 0,
                  right: 0,
                  child: TopBar(
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
