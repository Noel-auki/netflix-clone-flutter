import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netflix_clone/widgets/full_screen_button.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_control/volume_control.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoId;
  final String title;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoId,
    required this.title,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer>
    with SingleTickerProviderStateMixin {
  late YoutubePlayerController _youtubeController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _hideUITimer;
  bool _isPlaying = false;
  bool _uiVisible = true;
  double _currentSliderValue = 0.0;
  Duration _videoDuration = Duration.zero;
  double _brightness = 0.5;
  double _volume = 0.5;
  double _initialBrightness = 0.5;
  double _initialVolume = 0.5;

  @override
  void initState() {
    super.initState();

    // Set the preferred orientations to landscape only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      params: const YoutubePlayerParams(
        autoPlay: true,
        mute: false,
        showControls: false,
        enableCaption: false,
        showFullscreenButton: false,
        showVideoAnnotations: false,
        strictRelatedVideos: false,
      ),
    )
      ..hideTopMenu()
      ..hidePauseOverlay();

    _youtubeController.listen((event) {
      if (event.playerState == PlayerState.playing) {
        setState(() {
          _isPlaying = true;
          _videoDuration = event.metaData.duration;
        });
      } else if (event.playerState == PlayerState.paused) {
        setState(() {
          _isPlaying = false;
        });
      }
      if (event.playerState != PlayerState.buffering) {
        setState(() {
          _currentSliderValue = event.position.inSeconds
              .toDouble()
              .clamp(0, _videoDuration.inSeconds.toDouble());
        });
      }
    });

    // Initialize brightness and volume
    _initializeBrightnessAndVolume();

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

  void _initializeBrightnessAndVolume() async {
    _initialBrightness = await ScreenBrightness().current;
    _initialVolume = await VolumeControl.volume;
    setState(() {
      _brightness = _initialBrightness;
      _volume = _initialVolume;
    });
  }

  void _resetHideUITimer() {
    _hideUITimer?.cancel();
    _hideUITimer = Timer(const Duration(seconds: 5), () {
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
      if (_isPlaying) {
        _youtubeController.pause();
      } else {
        _youtubeController.play();
      }
      _isPlaying = !_isPlaying;
    });
    _resetHideUITimer();
  }

  void _rewind10Seconds() {
    _youtubeController.seekTo(Duration(
        seconds: (_youtubeController.value.position.inSeconds - 10)
            .clamp(0, _videoDuration.inSeconds)));
    _resetHideUITimer();
  }

  void _forward10Seconds() {
    _youtubeController.seekTo(Duration(
        seconds: (_youtubeController.value.position.inSeconds + 10)
            .clamp(0, _videoDuration.inSeconds)));
    _resetHideUITimer();
  }

  @override
  void dispose() {
    // Revert to the default orientation settings and brightness
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    ScreenBrightness().setScreenBrightness(_initialBrightness);
    VolumeControl.setVolume(_initialVolume);
    _youtubeController.close();
    _animationController.dispose();
    _hideUITimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return GestureDetector(
      onTap: _toggleUIVisibility,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              YoutubePlayerIFrame(
                controller: _youtubeController,
                aspectRatio: screenWidth / screenHeight,
              ),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    // Dimming overlay
                    Container(
                      color: Colors.black.withOpacity(0.7),
                    ),
                    // Back button at the top left
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: screenHeight * 0.07,
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
                    // Container for control buttons
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: screenHeight * 0.10,
                      top: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: screenHeight * 0.15,
                            ),
                            onPressed: _rewind10Seconds,
                          ),
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: screenHeight * 0.15,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: screenHeight * 0.15,
                            ),
                            onPressed: _forward10Seconds,
                          ),
                        ],
                      ),
                    ),
                    // Slider for video progress and remaining time in a row
                    Positioned(
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      bottom: screenHeight * 0.05,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 2.0,
                                  ),
                                  child: Slider(
                                    value: _currentSliderValue,
                                    min: 0,
                                    max:
                                        _videoDuration.inSeconds.toDouble() + 1,
                                    activeColor: Colors.red[900],
                                    inactiveColor: Colors.grey,
                                    onChanged: (value) {
                                      if (value <=
                                          _videoDuration.inSeconds.toDouble()) {
                                        setState(() {
                                          _currentSliderValue = value;
                                        });
                                        _youtubeController.seekTo(
                                            Duration(seconds: value.toInt()));
                                      }
                                      _resetHideUITimer();
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                _formatDuration(_videoDuration -
                                    Duration(
                                        seconds: _currentSliderValue.toInt())),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.04),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                            ],
                          ),
                          // Row for new buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconTextButton(
                                text: 'Lock',
                                icon: Icons.lock_open_outlined,
                                onTap: () {
                                  // Your onTap functionality for Lock button
                                },
                              ),
                              IconTextButton(
                                text: 'Episodes',
                                icon: Icons.video_library,
                                onTap: () {
                                  // Your onTap functionality for Episodes button
                                },
                              ),
                              IconTextButton(
                                text: 'Audio & Subtitles',
                                icon: Icons.subtitles_outlined,
                                onTap: () {
                                  // Your onTap functionality for Audio & Subtitles button
                                },
                              ),
                              IconTextButton(
                                text: 'Next Episode',
                                icon: Icons.skip_next_outlined,
                                onTap: () {
                                  // Your onTap functionality for Next Episode button
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Brightness control on the left
                    Positioned(
                      left: screenWidth * 0.05,
                      bottom: screenHeight * 0.20,
                      top: screenHeight * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.light_mode_outlined,
                            color: Colors.white,
                            size: screenHeight * 0.05,
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: SliderComponentShape.noThumb,
                              ),
                              child: Slider(
                                value: _brightness,
                                min: 0,
                                max: 1,
                                activeColor: Colors.white,
                                inactiveColor: Colors.grey,
                                onChanged: (value) {
                                  setState(() {
                                    _brightness = value;
                                    ScreenBrightness()
                                        .setScreenBrightness(value);
                                  });
                                  _resetHideUITimer();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Volume control on the right
                    Positioned(
                      right: screenWidth * 0.05,
                      bottom: screenHeight * 0.20,
                      top: screenHeight * 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.volume_up,
                            color: Colors.white,
                            size: screenHeight * 0.05,
                          ),
                          RotatedBox(
                            quarterTurns: 3,
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: SliderComponentShape.noThumb,
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
                                  });
                                  _resetHideUITimer();
                                },
                              ),
                            ),
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
