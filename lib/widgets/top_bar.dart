import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TopBar extends StatefulWidget {
  final Function(String) onCategorySelected;

  TopBar({required this.onCategorySelected});

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String selectedSection = 'Home';

  void _onCategorySelected(String category) {
    setState(() {
      selectedSection = category;
    });
    widget.onCategorySelected(category);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: kIsWeb ? 150 : 180,
      decoration: BoxDecoration(
        color: Colors.green,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(.8),
            Colors.black.withOpacity(.7),
            Colors.black.withOpacity(0),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: kIsWeb
              ? EdgeInsets.symmetric(
                  horizontal: 40.0) // Increased padding for web
              : EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _onCategorySelected('Home'),
                        child: SizedBox(
                          width: kIsWeb ? 100 : 40,
                          height: kIsWeb ? 100 : 40,
                          child: Image(
                            image: AssetImage(kIsWeb
                                ? "images/netflix_logo.png"
                                : "images/netfologo.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    if (kIsWeb)
                      SizedBox(
                          width:
                              20), // Adjust spacing between logo and menu items for web
                    if (kIsWeb)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _onCategorySelected('Home'),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "Home",
                                    style: TextStyle(
                                      color: selectedSection == 'Home'
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _onCategorySelected('TV Shows'),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "TV Shows",
                                    style: TextStyle(
                                      color: selectedSection == 'TV Shows'
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _onCategorySelected('Movies'),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "Movies",
                                    style: TextStyle(
                                      color: selectedSection == 'Movies'
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _onCategorySelected('My List'),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    "My List",
                                    style: TextStyle(
                                      color: selectedSection == 'My List'
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Icon(Icons.cast_outlined),
                            ),
                            SizedBox(width: 20),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Icon(Icons.account_circle_outlined),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    if (!kIsWeb)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Icon(Icons.cast_outlined),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: .1),
              if (!kIsWeb)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _onCategorySelected('Home'),
                      child: Text(
                        "All",
                        style: TextStyle(
                          color: selectedSection == 'Home'
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onCategorySelected('TV Shows'),
                      child: Text(
                        "TV Shows",
                        style: TextStyle(
                          color: selectedSection == 'TV Shows'
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onCategorySelected('Movies'),
                      child: Text(
                        "Movies",
                        style: TextStyle(
                          color: selectedSection == 'Movies'
                              ? Colors.white
                              : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
