import 'package:flutter/material.dart';
import 'package:netflix_clone/screens/full_screen_video_web.dart';
import 'package:netflix_clone/services/api.dart';

class VideoUtils {
  static Future<void> playMovieInFullScreen({
    required BuildContext context,
    required int movieId,
    required String movieTitle,
  }) async {
    final apiService = ApiService();
    final videoUrl = await apiService.fetchMovieVideo(movieId.toString());

    if (videoUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenVideoPlayerWeb(
            title: movieTitle,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load video')),
      );
    }
  }
}
