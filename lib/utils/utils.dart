class Utils {
  static const double movieItemWidth = 110.0;
  static const double movieItemHeight = 220.0;

  static double calculateAspectRatio(double screenWidth) {
    int crossAxisCount = (screenWidth / movieItemWidth).floor();
    return screenWidth / (crossAxisCount * movieItemHeight);
  }
}
