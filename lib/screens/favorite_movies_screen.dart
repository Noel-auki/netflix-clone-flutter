import 'package:flutter/material.dart';
import 'package:netflix_clone/widgets/movie_card.dart';
import 'package:netflix_clone/utils/movies_helper.dart';
import 'package:netflix_clone/utils/utils.dart';

class FavoriteMoviesScreen extends StatefulWidget {
  const FavoriteMoviesScreen({Key? key}) : super(key: key);

  @override
  _FavoriteMoviesScreenState createState() => _FavoriteMoviesScreenState();
}

class _FavoriteMoviesScreenState extends State<FavoriteMoviesScreen>
    with MoviesHelper {
  @override
  void initState() {
    super.initState();
    loadFavoriteMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'My List',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: favoriteMovies.isEmpty
                  ? Center(child: Text('No Movies in your List.'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        double screenWidth = constraints.maxWidth;
                        double aspectRatio =
                            Utils.calculateAspectRatio(screenWidth);

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (screenWidth / Utils.movieItemWidth).floor(),
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: favoriteMovies.length,
                          itemBuilder: (context, index) {
                            final movie = favoriteMovies[index];
                            String title = movie['title'] ?? 'No Title';
                            if (movie['media_type'] == 'tv') {
                              title = movie['name'] ?? 'No Title';
                            }
                            return GestureDetector(
                              onTap: () {
                                showMovieDetails(context, movie);
                              },
                              child: MovieCard(
                                image: NetworkImage(
                                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}'),
                                title: title,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
