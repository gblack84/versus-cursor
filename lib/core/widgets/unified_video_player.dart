import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/services/media/youtube_player_widget.dart';

/// A unified video player that automatically selects the appropriate player
/// based on the video URL (YouTube or regular video)
class UnifiedVideoPlayer extends StatelessWidget {
  const UnifiedVideoPlayer({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.aspectRatio,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.allowFullScreen = true,
    this.allowPlaybackSpeedMenu = false,
    this.pauseOnNavigate = true,
  });

  final String url;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool allowFullScreen;
  final bool allowPlaybackSpeedMenu;
  final bool pauseOnNavigate;

  @override
  Widget build(BuildContext context) {
    // Check if the URL is a YouTube URL
    if (isYouTubeUrl(url)) {
      return YouTubePlayerWidget(
        url: url,
        width: width,
        height: height,
        aspectRatio: aspectRatio ?? 16 / 9,
        autoPlay: autoPlay,
        loop: looping,
        showControls: showControls,
        fullScreenByDefault: false,
      );
    } else {
      // Use the regular video player for non-YouTube URLs
      return AppVideoPlayer(
        path: url,
        videoType: VideoType.network,
        width: width,
        height: height,
        aspectRatio: aspectRatio,
        autoPlay: autoPlay,
        looping: looping,
        showControls: showControls,
        allowFullScreen: allowFullScreen,
        allowPlaybackSpeedMenu: allowPlaybackSpeedMenu,
        pauseOnNavigate: pauseOnNavigate,
      );
    }
  }
}
