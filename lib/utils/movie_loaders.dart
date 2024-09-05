import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netflix_clone/widgets/movie_card.dart';

class MovieLoaders {
  static String _getImageUrl(Map<String, dynamic> item) {
    final String path = kIsWeb ? item['poster_path'] : item['poster_path'];
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  static Widget _buildScrollableList(
      List<dynamic> items, Function showMovieDetails) {
    ScrollController _scrollController = ScrollController();

    void _scrollLeft() {
      _scrollController.animateTo(
        _scrollController.position.pixels - 300,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }

    void _scrollRight() {
      _scrollController.animateTo(
        _scrollController.position.pixels + 300,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: kIsWeb
              ? const EdgeInsets.symmetric(horizontal: 40)
              : const EdgeInsets.symmetric(horizontal: 10),
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          child: Row(
            children: items.map((item) {
              String title = item['title'] ?? item['name'] ?? 'No Title';

              return GestureDetector(
                onTap: () {
                  showMovieDetails(item);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: MovieCard(
                    image: NetworkImage(_getImageUrl(item)),
                    title: title,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (kIsWeb)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
            ),
          ),
        if (kIsWeb)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ),
          ),
      ],
    );
  }

  static Widget loadPopularAll(
      List<dynamic> popularAll, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Trending On Netflix",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildScrollableList(popularAll, showMovieDetails),
        ],
      ),
    );
  }

  static Widget loadPopularMovies(
      List<dynamic> popularMovies, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Popular Movies",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildScrollableList(popularMovies, showMovieDetails),
        ],
      ),
    );
  }

  static Widget loadTrendingNow(
      List<dynamic> trendingMovies, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Trending Movies",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildScrollableList(trendingMovies, showMovieDetails),
        ],
      ),
    );
  }

  static Widget loadNewReleases(
      List<dynamic> newReleasesMovies, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "New Releases",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildScrollableList(newReleasesMovies, showMovieDetails),
        ],
      ),
    );
  }

  static Widget loadPopularTVShows(
      List<dynamic> popularTVShows, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Popular TV Shows",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildScrollableList(popularTVShows, showMovieDetails),
        ],
      ),
    );
  }

  static Widget loadTrendingTVShows(
      List<dynamic> trendingTVShows, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "Trending TV Shows",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildScrollableList(trendingTVShows, showMovieDetails),
        ],
      ),
    );
  }

  static Widget loadMyList(List<dynamic> myList, Function showMovieDetails) {
    return Padding(
      padding: kIsWeb
          ? const EdgeInsets.symmetric(horizontal: 30)
          : const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              "My List",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (myList.isEmpty) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "No Movies in your List.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              height:
                  250, // Set a fixed height to make the ListView work inside a Column
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: myList.length,
                itemBuilder: (context, index) {
                  final item = myList[index];
                  String title = item['title'] ?? item['name'] ?? 'No Title';
                  return GestureDetector(
                    onTap: () {
                      showMovieDetails(item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: MovieCard(
                        image: NetworkImage(_getImageUrl(item)),
                        title: title,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
