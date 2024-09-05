import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = 'b8735916ebe69a988e7a757928558cf0';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String genreUrl =
      'https://api.themoviedb.org/3/genre/movie/list?api_key=b8735916ebe69a988e7a757928558cf0&language=en-US';

  Future<List<dynamic>> fetchTrendingAll({int page = 1}) async {
    print("Hit Api");
    final response = await http.get(Uri.parse(
        '$baseUrl/trending/all/day?api_key=$apiKey&language=en-US&page=$page'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load trending content');
    }
  }

  Future<List<dynamic>> fetchPopularMovies({int page = 1}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<dynamic>> fetchTrendingMovies({int page = 1}) async {
    final response = await http.get(
        Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<dynamic>> fetchNewReleasesMovies({int page = 1}) async {
    final response = await http.get(
        Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load new releases');
    }
  }

  Future<List<dynamic>> fetchPopularTVShows({int page = 1}) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/tv/popular?api_key=$apiKey&language=en-US&page=$page'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load popular TV shows');
    }
  }

  Future<List<dynamic>> fetchTrendingTVShows({int page = 1}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/trending/tv/week?api_key=$apiKey&page=$page'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load trending TV shows');
    }
  }

  Future<Map<int, String>> fetchGenres() async {
    final response = await http.get(Uri.parse(genreUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final genres = <int, String>{};
      for (var genre in data['genres']) {
        genres[genre['id']] = genre['name'];
      }
      return genres;
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<String?> fetchMovieVideo(String movieId) async {
    final url = '$baseUrl/movie/$movieId/videos?language=en-US&api_key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      if (results.isNotEmpty) {
        final video = results.firstWhere(
          (element) => element['site'] == 'YouTube',
          orElse: () => null,
        );
        return video != null
            ? 'https://www.youtube.com/watch?v=${video['key']}rel=0'
            : null;
      }
    } else {
      throw Exception('Failed to load video');
    }
    return null;
  }
}
