import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:netflix_clone/utils/navigation_utils.dart';
import 'package:netflix_clone/widgets/bottom_modal_button.dart';
import 'package:netflix_clone/utils/share_utils.dart';

class BottomModal extends StatefulWidget {
  final dynamic movie;
  final Function(dynamic) onAddToFavorite;
  final List<dynamic> favoriteMovies;

  const BottomModal({
    Key? key,
    required this.movie,
    required this.onAddToFavorite,
    required this.favoriteMovies,
  }) : super(key: key);

  @override
  _BottomModalState createState() => _BottomModalState();
}

class _BottomModalState extends State<BottomModal> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    int movieId = widget.movie['id'];
    isFavorite =
        widget.favoriteMovies.any((favMovie) => favMovie['id'] == movieId);
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      widget.onAddToFavorite(widget.movie);
    });
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl =
        'https://image.tmdb.org/t/p/w500${widget.movie['poster_path']}';
    String title =
        widget.movie['title'] ?? widget.movie['name'] ?? 'Unknown Title';
    String? releaseDate =
        widget.movie['release_date'] ?? widget.movie['first_air_date'];
    int? releaseYear =
        releaseDate != null ? DateTime.parse(releaseDate).year : null;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  imageUrl,
                  width: 88.0,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
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
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.movie['overview'] ?? 'No overview available.',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(100.0),
                radius: 32.0,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(
                    LucideIcons.x,
                    size: 28.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomSheetButton(
                icon: Icons.play_arrow,
                label: 'Play',
                light: true,
                onPressed: () => navigateToPreviewPage(context, widget.movie),
              ),
              _buildBottomSheetButton(
                icon: LucideIcons.download,
                label: 'Download',
              ),
              _buildBottomSheetButton(
                icon: isFavorite ? Icons.check : LucideIcons.plus,
                label: 'My List',
                onPressed: _toggleFavorite,
              ),
              _buildBottomSheetButton(
                icon: LucideIcons.share2,
                label: 'Share',
                onPressed: () => ShareUtils.shareMovie(
                    widget.movie), // Use the utility class
              ),
            ],
          ),
          const Divider(),
          InkWell(
            onTap: () {
              navigateToPreviewPage(context, widget.movie);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.info),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text('Details & More'),
                  ],
                ),
                Icon(LucideIcons.chevronRight)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetButton({
    required IconData icon,
    required String label,
    bool light = false,
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: BottomSheetButton(
        icon: icon,
        label: label,
        size: 28.0,
        light: light,
        onPressed: onPressed,
      ),
    );
  }
}
