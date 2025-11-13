import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerWidget extends StatefulWidget {
  const YouTubePlayerWidget({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
    this.mute = false,
    this.loop = false,
    this.showControls = true,
    this.fullScreenByDefault = false,
  });

  final String url;
  final double? width;
  final double? height;
  final double aspectRatio;
  final bool autoPlay;
  final bool mute;
  final bool loop;
  final bool showControls;
  final bool fullScreenByDefault;

  @override
  State<YouTubePlayerWidget> createState() => _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends State<YouTubePlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.url);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: widget.mute,
        loop: widget.loop,
        controlsVisibleAtStart: widget.showControls,
        hideControls: !widget.showControls,
        forceHD: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }

    // YouTube video ID extraction logic
    // Handle various YouTube URL formats
    if (uri.host.contains('youtube.com') ||
        uri.host.contains('www.youtube.com')) {
      // Standard YouTube URLs
      final videoId = uri.queryParameters['v'];
      if (videoId != null) {
        return videoId;
      }

      // YouTube embed URLs
      if (uri.pathSegments.contains('embed') && uri.pathSegments.length > 2) {
        return uri.pathSegments[2];
      }
    } else if (uri.host.contains('youtu.be')) {
      // Short YouTube URLs
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments[0];
      }
    }

    // Try to extract video ID using the package's built-in converter
    return YoutubePlayer.convertUrlToId(url);
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _extractVideoId(widget.url);

    if (videoId == null || videoId.isEmpty) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 200,
        color: Colors.black,
        child: const Center(
          child: Text(
            'Invalid YouTube URL',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          if (widget.fullScreenByDefault) {
            _controller.toggleFullScreenMode();
          }
        },
      ),
      builder: (context, player) {
        return Container(
          width: widget.width,
          height: widget.height,
          child: widget.width != null || widget.height != null
              ? AspectRatio(
                  aspectRatio: widget.aspectRatio,
                  child: player,
                )
              : player,
        );
      },
    );
  }
}

// Helper function to check if a URL is a YouTube URL
bool isYouTubeUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;

  return uri.host.contains('youtube.com') ||
      uri.host.contains('youtu.be') ||
      uri.host.contains('www.youtube.com');
}

// Helper function to extract YouTube video ID from URL
String? extractYouTubeVideoId(String url) {
  return YoutubePlayer.convertUrlToId(url);
}
