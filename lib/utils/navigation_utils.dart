import 'package:flutter/material.dart';
import 'package:netflix_clone/screens/preview_screen.dart';

void navigateToPreviewPage(BuildContext context, dynamic movie) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PreviewPage(
        movie: movie,
      ),
    ),
  );
}
