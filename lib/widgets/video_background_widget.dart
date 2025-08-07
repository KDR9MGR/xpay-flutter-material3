import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../utils/app_logger.dart';

class VideoBackgroundWidget extends StatefulWidget {
  final String videoPath;
  final Widget child;

  const VideoBackgroundWidget({
    super.key,
    required this.videoPath,
    required this.child,
  });

  @override
  State<VideoBackgroundWidget> createState() => _VideoBackgroundWidgetState();
}

class _VideoBackgroundWidgetState extends State<VideoBackgroundWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // For now, we'll use a placeholder since we don't have an actual video file
      // In production, you would use: _controller = VideoPlayerController.asset(widget.videoPath);

      // Using a video showing people using phones for mobile payments
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
        ),
      );

      await _controller.initialize();

      // Mute the video (no volume as requested)
      await _controller.setVolume(0.0);

      // Set to loop continuously
      await _controller.setLooping(true);

      // FIXED: Set playback speed to 8x for very fast playback
      await _controller.setPlaybackSpeed(8.0);

      // Start playing
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Silently handle video initialization errors
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      if (_isInitialized && _controller.value.isInitialized) {
        _controller.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
      AppLogger.error('Video disposal error: $e', tag: 'VideoBackgroundWidget', error: e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: widget.child,
      );
    }

    return Stack(
      children: [
        // Video background
        if (_controller.value.isInitialized)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),

        // Dark overlay to ensure text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),

        // Content on top
        widget.child,
      ],
    );
  }
}

// Simplified video widget for use as a decorative element
class SimpleVideoWidget extends StatefulWidget {
  final double height;
  final BorderRadius? borderRadius;

  const SimpleVideoWidget({super.key, this.height = 200, this.borderRadius});

  @override
  State<SimpleVideoWidget> createState() => _SimpleVideoWidgetState();
}

class _SimpleVideoWidgetState extends State<SimpleVideoWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Video showing people using mobile payment apps
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        ),
      );

      await _controller.initialize();
      await _controller.setVolume(0.0);
      await _controller.setLooping(true);
      // FIXED: Set playback speed to 8x for very fast playback
      await _controller.setPlaybackSpeed(8.0);
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppLogger.error('Error initializing video: $e', tag: 'SimpleVideo', error: e);
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      if (_isInitialized && !_hasError && _controller.value.isInitialized) {
        _controller.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
      AppLogger.error('SimpleVideo disposal error: $e', tag: 'SimpleVideo', error: e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        color: Colors.grey[900],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        child:
            _isInitialized && !_hasError && _controller.value.isInitialized
                ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Fixed aspect ratio and alignment to prevent overflow
                    FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    // Gradient overlay for better text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                : Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue.withValues(alpha: 0.3),
                        Colors.purple.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isInitialized)
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.7),
                            ),
                            strokeWidth: 2,
                          )
                        else if (_hasError)
                          Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.5),
                          )
                        else
                          Icon(
                            Icons.smartphone_rounded,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            !_isInitialized
                                ? 'Loading video...'
                                : _hasError
                                ? 'Video unavailable'
                                : 'People Using Digital Payments',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}

/// YouTube Video Widget for playing YouTube videos
class YouTubeVideoWidget extends StatefulWidget {
  final double height;
  final double? borderRadius;
  final String videoId;

  const YouTubeVideoWidget({
    super.key,
    this.height = 200,
    this.borderRadius,
    required this.videoId,
  });

  @override
  State<YouTubeVideoWidget> createState() => _YouTubeVideoWidgetState();
}

class _YouTubeVideoWidgetState extends State<YouTubeVideoWidget> {
  late YoutubePlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: widget.videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          mute: true,
          showControls: false,
          showFullscreenButton: false,
          loop: true,
          enableCaption: false,
          showVideoAnnotations: false,
        ),
      );

      // Set playback rate to 2x after controller is ready
      _controller.setPlaybackRate(2.0);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      AppLogger.error('Error initializing YouTube video: $e', tag: 'YouTubeVideo', error: e);
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void dispose() {
    try {
      _controller.close();
    } catch (e) {
      AppLogger.error('YouTube video disposal error: $e', tag: 'YouTubeVideoWidget', error: e);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius != null
            ? BorderRadius.circular(widget.borderRadius!)
            : null,
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius != null
            ? BorderRadius.circular(widget.borderRadius!)
            : BorderRadius.zero,
        child: _isInitialized
            ? (_hasError
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white54,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'YouTube video unavailable',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ))
            : const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                ),
              ),
      ),
    );
  }
}
