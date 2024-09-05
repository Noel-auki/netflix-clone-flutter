import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:netflix_clone/screens/FullScreenVideoPlayer.dart';
import 'package:netflix_clone/services/api.dart';
import 'package:netflix_clone/utils/share_utils.dart';
import 'package:netflix_clone/utils/storage_helper.dart';
import 'package:netflix_clone/widgets/bottom_modal.dart';
import 'package:netflix_clone/widgets/movie_card.dart';
import 'package:netflix_clone/widgets/preview_screen_button.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart'
    as youtube_iframe;

class PreviewPage extends StatefulWidget {
  final dynamic movie;

  const PreviewPage({
    Key? key,
    required this.movie,
  }) : super(key: key);

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  final ApiService apiService = ApiService();
  List<dynamic> favoriteMovies = [];
  List<dynamic> likedMovies = [];
  List<dynamic> trendingMovies = [];
  late VideoPlayerController _videoController;
  youtube_iframe.YoutubePlayerController? _youtubeController;
  bool _isVideoInitialized = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    loadFavoriteMovies();
    loadLikedMovies();
    fetchTrendingMovies();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    final videoUrl =
        await apiService.fetchMovieVideo(widget.movie['id'].toString());

    if (videoUrl != null) {
      _youtubeController = youtube_iframe.YoutubePlayerController(
        initialVideoId:
            youtube_iframe.YoutubePlayerController.convertUrlToId(videoUrl) ??
                '',
        params: youtube_iframe.YoutubePlayerParams(
          autoPlay: true,
          loop: true,
          showControls: false,
          showFullscreenButton: false,
          mute: _isMuted,
          showVideoAnnotations: false,
          strictRelatedVideos: false,
          enableCaption: false,
        ),
      );

      setState(() {
        _isVideoInitialized = true;
      });
    } else {
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  Future<void> loadFavoriteMovies() async {
    final loadedMovies = await StorageHelper.loadFavoriteMovies();
    setState(() {
      favoriteMovies = loadedMovies;
    });
  }

  Future<void> saveFavoriteMovies() async {
    await StorageHelper.saveFavoriteMovies(favoriteMovies);
  }

  Future<void> loadLikedMovies() async {
    final loadedMovies = await StorageHelper.loadLikedMovies();
    setState(() {
      likedMovies = loadedMovies;
    });
  }

  Future<void> saveLikedMovies() async {
    await StorageHelper.saveLikedMovies(likedMovies);
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

      saveFavoriteMovies();
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

      saveLikedMovies();
    });
  }

  Future<void> fetchTrendingMovies() async {
    final fetchedTrendingMovies = await apiService.fetchTrendingMovies();
    setState(() {
      trendingMovies = fetchedTrendingMovies;
    });
  }

  void _showMovieDetails(dynamic movieData) {
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

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_youtubeController != null) {
        if (_isMuted) {
          _youtubeController!.mute();
        } else {
          _youtubeController!.unMute();
        }
      }
    });
  }

  void _playFullScreenVideo() {
    if (_youtubeController != null) {
      _youtubeController!.play();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayer(
            videoId: _youtubeController!.initialVideoId,
            title: widget.movie['title'] ?? 'No Title',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title =
        widget.movie['title'] ?? widget.movie['name'] ?? 'Unknown Title';
    String? releaseDate =
        widget.movie['release_date'] ?? widget.movie['first_air_date'];
    int? releaseYear =
        releaseDate != null ? DateTime.parse(releaseDate).year : null;
    bool isFavorite =
        favoriteMovies.any((favMovie) => favMovie['id'] == widget.movie['id']);
    bool isLiked =
        likedMovies.any((likedMovie) => likedMovie['id'] == widget.movie['id']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cast_outlined),
            onPressed: () {
              // Handle cast button action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _isVideoInitialized
                    ? SizedBox(
                        width: double.infinity,
                        height: 245.0,
                        child: youtube_iframe.YoutubePlayerIFrame(
                          controller: _youtubeController,
                          aspectRatio: 16 / 9,
                        ),
                      )
                    : Container(
                        color: Colors.grey,
                        width: double.infinity,
                        height: 200.0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                Positioned(
                  bottom: 12.0,
                  left: 6.0,
                  child: SizedBox(
                    height: 32.0,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0)),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black.withOpacity(.3),
                      ),
                      onPressed: () {},
                      child: const Text('Preview'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6.0,
                  right: 6.0,
                  child: IconButton(
                    onPressed: _toggleMute,
                    icon: Icon(
                        _isMuted ? LucideIcons.volumeX : LucideIcons.volume2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Text(
                        releaseYear != null ? '$releaseYear' : 'Year N/A',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      if (widget.movie['adult'] == true) ...[
                        const Text(
                          '18+',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                      Text(
                        'Language: ${widget.movie['original_language']}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.0),
                          color: Colors.grey.shade300,
                        ),
                        child: const Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: _playFullScreenVideo,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              backgroundColor: Colors.grey.shade900,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {},
                            icon: const Icon(LucideIcons.download),
                            label: const Text('Download'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie['overview'] ?? 'No overview available.',
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        const Text(
                            'Starring: Bob Odenkirk, Jonathan Banks, Rhea Seehorn...'),
                        const SizedBox(
                          height: 8.0,
                        ),
                        const Text('Creators: Vince Gilligan, Peter Gould'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    addToFavorite(widget.movie);
                  },
                  child: Column(
                    children: [
                      Icon(
                        isFavorite ? Icons.check : Icons.add,
                      ),
                      SizedBox(height: 12),
                      Text("My List"),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    addToLiked(widget.movie);
                  },
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                              child: child, scale: animation);
                        },
                        child: Icon(
                          isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          key: ValueKey<bool>(isLiked),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text("Rate"),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ShareUtils.shareMovie(widget.movie);
                  },
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.share2,
                      ),
                      SizedBox(height: 12),
                      Text("Share"),
                    ],
                  ),
                ),
                PreviewScreenButton(
                  icon: LucideIcons.download,
                  label: 'Download',
                )
              ],
            ),
            SizedBox(height: 20.0),
            loadTrendingNow(),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget loadTrendingNow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            "Recommended Movies",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 10),
          physics: BouncingScrollPhysics(),
          child: Row(
            children: trendingMovies.map((movie) {
              return GestureDetector(
                onTap: () {
                  _showMovieDetails(movie);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: MovieCard(
                    image: NetworkImage(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}'),
                    title: movie['title'] ?? 'No Title',
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
