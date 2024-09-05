import 'dart:async';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:netflix_clone/utils/navigation_utils.dart';
import 'package:netflix_clone/utils/video_utils_navigation.dart';
import 'package:netflix_clone/widgets/bottom_modal.dart';
import 'package:netflix_clone/widgets/genre_text.dart';

class SpecialMovie extends StatefulWidget {
  final List<String> images;
  final List<String> genres;
  final List<dynamic> movies;
  final Function(dynamic) onAddToMyList;
  final List<dynamic> favoriteMovies;
  final dynamic selectedMovie;
  final bool enableSlideshow;

  const SpecialMovie({
    Key? key,
    required this.images,
    required this.genres,
    required this.movies,
    required this.onAddToMyList,
    required this.favoriteMovies,
    this.selectedMovie,
    this.enableSlideshow = true,
  }) : super(key: key);

  @override
  _SpecialMovieState createState() => _SpecialMovieState();
}

class _SpecialMovieState extends State<SpecialMovie> {
  late PageController _pageController;
  int _currentPage = 0;
  late String movieTitle;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Timer for automatic page change
    if (widget.enableSlideshow) {
      Timer.periodic(const Duration(seconds: 8), (Timer timer) {
        if (_pageController.hasClients) {
          int nextPage = (_currentPage + 1) % widget.images.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showBottomModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomModal(
          movie: widget.movies[_currentPage],
          onAddToFavorite: widget.onAddToMyList,
          favoriteMovies: widget.favoriteMovies,
        );
      },
    );
  }

  String _constructImageUrl(String path) {
    return 'https://image.tmdb.org/t/p/w500$path';
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = widget.favoriteMovies
        .any((movie) => movie['id'] == widget.movies[_currentPage]['id']);

    // Get the title or name
    if (kIsWeb) {
      movieTitle =
          widget.selectedMovie['title'] ?? widget.selectedMovie['name'];
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .75,
      child: Stack(
        children: [
          // Page view for images
          if (widget.enableSlideshow) ...[
            PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // Image container
                    Container(
                      constraints: const BoxConstraints.expand(),
                      child: Image(
                        image: NetworkImage(widget.images[index]),
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    // Genre text at bottom
                    if (!kIsWeb)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 80),
                          child: GenreText(
                            genre: widget.genres[index],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ] else ...[
            // Highlight the selected movie on the web

            Stack(
              children: [
                Container(
                  constraints: const BoxConstraints.expand(),
                  child: Image(
                    image: NetworkImage(
                      _constructImageUrl(widget.selectedMovie['backdrop_path']),
                    ),
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                if (!kIsWeb)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: GenreText(
                        genre: widget.genres[0],
                      ),
                    ),
                  ),
              ],
            ),
          ],
          // Gradient line at the bottom
          Positioned(
            bottom: -1,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          // Bottom content column
          Positioned(
            bottom: kIsWeb ? 100 : 20,
            left: kIsWeb ? 30 : 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 20),
                      child: Text(
                        movieTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: kIsWeb
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.spaceEvenly,
                    children: [
                      if (kIsWeb) ...[
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              VideoUtils.playMovieInFullScreen(
                                context: context,
                                movieId: widget.selectedMovie['id'],
                                movieTitle: widget.selectedMovie['title'],
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[850]!.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    "Play",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              widget.onAddToMyList(widget.selectedMovie);
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[850]!.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isFavorite ? Icons.check : Icons.add,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text(
                                    "My List",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget
                                    .onAddToMyList(widget.movies[_currentPage]);
                                setState(() {});
                              },
                              child: Icon(
                                isFavorite ? Icons.check : Icons.add,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text("My List"),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            navigateToPreviewPage(
                                context, widget.movies[_currentPage]);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  "Play",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _showBottomModal(context),
                              child: const Icon(Icons.info_outline),
                            ),
                            const SizedBox(height: 2),
                            const Text("Info"),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Text(
                          widget.selectedMovie['overview'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
