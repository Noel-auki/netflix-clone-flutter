import 'package:flutter/material.dart';

class GenreText extends StatelessWidget {
  final String genre;

  const GenreText({Key? key, required this.genre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split the genre string by the separator ' • ' and create TextSpans
    final genreParts = genre.split(' • ');
    List<TextSpan> textSpans = [];

    for (int i = 0; i < genreParts.length; i++) {
      textSpans.add(TextSpan(text: genreParts[i]));
      if (i < genreParts.length - 1) {
        textSpans.add(TextSpan(
          text: ' • ',
          style: TextStyle(color: Colors.red),
        ));
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 16),
          children: textSpans,
        ),
      ),
    );
  }
}
