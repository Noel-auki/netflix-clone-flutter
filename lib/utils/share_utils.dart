import 'package:share/share.dart';

class ShareUtils {
  static void shareMovie(dynamic movie) {
    String title = movie['title'] ?? movie['name'] ?? 'Unknown Title';
    String shareLink = 'https://dummysharelink.com/movie/${movie['id']}';
    Share.share('Check out this movie: $title\n\n$shareLink');
  }
}
