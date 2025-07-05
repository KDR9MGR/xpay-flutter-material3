import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Super fast animated background as alternative to slow videos
class SuperFastAnimatedBackground extends StatefulWidget {
  final Widget child;
  final double height;
  final BorderRadius? borderRadius;
  
  const SuperFastAnimatedBackground({
    super.key,
    required this.child,
    this.height = 200,
    this.borderRadius,
  });

  @override
  State<SuperFastAnimatedBackground> createState() => _SuperFastAnimatedBackgroundState();
}

class _SuperFastAnimatedBackgroundState extends State<SuperFastAnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _scaleController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 100), // Very fast color changes
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150), // Very fast scaling
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: Colors.blue.withValues(alpha: 0.3),
      end: Colors.purple.withValues(alpha: 0.5),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticInOut,
    ));
    
    // Start the super fast animations
    _startFastAnimation();
  }

  void _startFastAnimation() {
    _colorController.repeat(reverse: true);
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _colorController.dispose();
    _scaleController.dispose();
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
        child: AnimatedBuilder(
          animation: Listenable.merge([_colorController, _scaleController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _colorAnimation.value ?? Colors.blue.withValues(alpha: 0.3),
                      Colors.cyan.withValues(alpha: 0.4),
                      Colors.purple.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Fast moving particles effect
                    ...List.generate(5, (index) {
                      return Positioned(
                        left: (index * 50.0) + (_scaleAnimation.value * 20),
                        top: (index * 30.0) + (_colorController.value * 100),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                    // Content overlay
                    widget.child,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

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
        Uri.parse('https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4')
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
      _controller.dispose();
    } catch (e) {
      // Ignore disposal errors
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
  
  const SimpleVideoWidget({
    super.key,
    this.height = 200,
    this.borderRadius,
  });

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
        Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4')
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
      print('Error initializing video: $e');
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
      if (_isInitialized && !_hasError) {
        _controller.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
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
        child: _isInitialized && !_hasError && _controller.value.isInitialized
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
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
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

// YouTube video widget for the specific video
class YouTubeVideoWidget extends StatefulWidget {
  final double height;
  final BorderRadius? borderRadius;
  
  const YouTubeVideoWidget({
    super.key,
    this.height = 200,
    this.borderRadius,
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
    _initializeYouTubePlayer();
  }

  void _initializeYouTubePlayer() {
    try {
      // Extract video ID from the YouTube URL: https://youtu.be/TVIxF-SZFlo?t=17
      const String videoId = 'TVIxF-SZFlo';
      
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: true, // Muted as requested
          loop: true,
          startAt: 17, // Start at 17 seconds as specified in the URL
          enableCaption: false,
          showLiveFullscreenButton: false,
          controlsVisibleAtStart: false,
          hideControls: true,
          forceHD: false, // Lower quality for faster loading
        ),
      );
      
      // Set playback speed to maximum for YouTube (2x is max for YT)
      _controller.setPlaybackRate(2.0);
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Silently handle YouTube initialization errors
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
      if (_isInitialized && !_hasError) {
        _controller.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
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
        child: _isInitialized && !_hasError
            ? Stack(
                fit: StackFit.expand,
                children: [
                  // YouTube Player
                  YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: false,
                    progressIndicatorColor: Colors.transparent,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.transparent,
                      handleColor: Colors.transparent,
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
                      Colors.red.withValues(alpha: 0.3),
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
                          Icons.play_circle_outline_rounded,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          !_isInitialized
                              ? 'Loading YouTube video...'
                              : _hasError
                                  ? 'YouTube video unavailable'
                                  : 'Digital Payment Demo',
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