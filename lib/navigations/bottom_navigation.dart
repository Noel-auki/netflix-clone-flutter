import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:netflix_clone/screens/home_page.dart';
import 'package:netflix_clone/screens/favorite_movies_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedBottom = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: kIsWeb
          ? null
          : BottomNavigationBar(
              selectedFontSize: 10,
              unselectedFontSize: 10,
              onTap: (int index) {
                setState(() {
                  _selectedBottom = index;
                });
              },
              currentIndex: _selectedBottom,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border), label: "My List"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.file_download_outlined),
                  label: "Downloads",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: "More",
                ),
              ],
            ),
      body: Stack(
        children: [
          Visibility(
            child: HomeView(),
            visible: _selectedBottom == 0,
          ),
          Visibility(
            child: FavoriteMoviesScreen(),
            visible: _selectedBottom == 1,
          ),
          Visibility(
            child: Center(
              child: Text("Download View"),
            ),
            visible: _selectedBottom == 2,
          ),
          Visibility(
            child: Center(
              child: Text("More View"),
            ),
            visible: _selectedBottom == 3,
          ),
        ],
      ),
    );
  }
}
