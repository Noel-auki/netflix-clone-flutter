import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_control/volume_control.dart';

class FullScreenVideoPlayerWeb extends StatefulWidget {
  final String title;

  const FullScreenVideoPlayerWeb({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerWebState createState() =>
      _FullScreenVideoPlayerWebState();
}

class _FullScreenVideoPlayerWebState extends State<FullScreenVideoPlayerWeb>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _hideUITimer;
  bool _isPlaying = true;
  bool _uiVisible = true;

  double _currentSliderValue = 0.0;
  Duration _videoDuration = Duration.zero;
  double _volume = 0.5;
  double _initialVolume = 0.5;
  double _previousVolume = 0.5;
  bool _muted = false;

  @override
  void initState() {
    super.initState();

    _videoController = VideoPlayerController.asset('images/movie.mp4')
      ..initialize().then((_) {
        setState(() {
          _videoDuration = _videoController.value.duration;
        });
        _videoController.play();
        _isPlaying = true;
      });

    _videoController.addListener(() {
      setState(() {
        if (_videoController.value.isPlaying) {
          _isPlaying = true;
        } else {
          _isPlaying = false;
        }
        _currentSliderValue = _videoController.value.position.inSeconds
            .toDouble()
            .clamp(0, _videoDuration.inSeconds.toDouble());
      });
    });

    // Initialize volume
    _initializeVolume();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);

    // Start timer to hide UI
    _resetHideUITimer();
  }

  void _initializeVolume() async {
    _initialVolume = await VolumeControl.volume;
    setState(() {
      _volume = _initialVolume;
      _previousVolume = _initialVolume;
    });
  }

  void _resetHideUITimer() {
    _hideUITimer?.cancel();
    _hideUITimer = Timer(const Duration(seconds: 10), () {
      if (_uiVisible) {
        _animationController.forward();
        setState(() {
          _uiVisible = false;
        });
      }
    });
  }

  void _toggleUIVisibility() {
    _hideUITimer?.cancel();
    if (_uiVisible) {
      _animationController.forward();
      setState(() {
        _uiVisible = false;
      });
    } else {
      _animationController.reverse();
      setState(() {
        _uiVisible = true;
      });
      _resetHideUITimer();
    }
  }

  void _togglePlayPause() {
    setState(() {
      print('initially . _isPlaying: $_isPlaying');
      if (_isPlaying) {
        _videoController.pause();
        _isPlaying = true;
      } else {
        _videoController.play();
        _isPlaying = false;
      }
      _isPlaying = !_isPlaying;
      print('Toggled play/pause. _isPlaying: $_isPlaying');
    });
    _resetHideUITimer();
  }

  void _showUI() {
    if (!_uiVisible) {
      _animationController.reverse();
      setState(() {
        _uiVisible = true;
      });
    }
    _resetHideUITimer();
  }

  void _rewind10Seconds() {
    final newPosition = Duration(
        seconds: (_videoController.value.position.inSeconds - 10)
            .clamp(0, _videoDuration.inSeconds));
    _videoController.seekTo(newPosition);
    _resetHideUITimer();
  }

  void _forward10Seconds() {
    final newPosition = Duration(
        seconds: (_videoController.value.position.inSeconds + 10)
            .clamp(0, _videoDuration.inSeconds));
    _videoController.seekTo(newPosition);
    _resetHideUITimer();
  }

  void _toggleMute() {
    setState(() {
      if (_muted) {
        _volume = _previousVolume;
        VolumeControl.setVolume(_previousVolume);
      } else {
        _previousVolume = _volume;
        _volume = 0.0;
        VolumeControl.setVolume(0.0);
      }
      _muted = !_muted;
    });
    _resetHideUITimer();
  }

  @override
  void dispose() {
    // Revert to the default orientation settings and volume
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    VolumeControl.setVolume(_initialVolume);
    _videoController.dispose();
    _animationController.dispose();
    _hideUITimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    return GestureDetector(
      onTap: () {
        _togglePlayPause();
        _toggleUIVisibility();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: MouseRegion(
            onHover: (event) {
              _showUI();
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                VideoPlayer(_videoController),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black.withOpacity(0.7),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      // Movie title at the top center
                      Positioned(
                        top: screenHeight * 0.03,
                        left: 0,
                        right: 0,
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.04,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      // Slider for video progress and remaining time in a row
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 10,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 2.0,
                                        thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 6.0,
                                        ),
                                      ),
                                      child: Slider(
                                        value: _currentSliderValue,
                                        min: 0,
                                        max:
                                            _videoDuration.inSeconds.toDouble(),
                                        activeColor: Colors.red[900],
                                        inactiveColor: Colors.grey,
                                        onChanged: (value) {
                                          if (value <=
                                              _videoDuration.inSeconds
                                                  .toDouble()) {
                                            setState(() {
                                              _currentSliderValue = value;
                                            });
                                            _videoController.seekTo(Duration(
                                                seconds: value.toInt()));
                                          }
                                          _resetHideUITimer();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  _formatDuration(_videoDuration -
                                      Duration(
                                          seconds:
                                              _currentSliderValue.toInt())),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(width: 20),
                              ],
                            ),
                            // Row for new buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: _togglePlayPause,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: _rewind10Seconds,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.forward_10,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: _forward10Seconds,
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        _muted
                                            ? Icons.volume_off
                                            : Icons.volume_up,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: _toggleMute,
                                    ),
                                    RotatedBox(
                                      quarterTurns: 4,
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 2.0,
                                          thumbShape:
                                              SliderComponentShape.noThumb,
                                        ),
                                        child: Slider(
                                          value: _volume,
                                          min: 0,
                                          max: 1,
                                          activeColor: Colors.white,
                                          inactiveColor: Colors.grey,
                                          onChanged: (value) {
                                            setState(() {
                                              _volume = value;
                                              VolumeControl.setVolume(value);
                                              if (value == 0) {
                                                _muted = true;
                                              } else {
                                                _muted = false;
                                              }
                                            });
                                            _resetHideUITimer();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.skip_next_outlined,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        // Your onTap functionality for Fullscreen button
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.subtitles_outlined,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        // Your onTap functionality for Fullscreen button
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        // Your onTap functionality for Fullscreen button
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
