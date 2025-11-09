import '/core_exports.dart';
// Previous: /core/app_theme.dart';
// Previous: /core/app_utils.dart';
// Previous: /core/app_video_player.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // 삭제: AppState 사용 안 함
import 'videoplay_model.dart';
export 'videoplay_model.dart';

class VideoplayWidget extends StatefulWidget {
  const VideoplayWidget({
    super.key,
    this.videoUrl,
  });

  final String? videoUrl;

  @override
  State<VideoplayWidget> createState() => _VideoplayWidgetState();
}

class _VideoplayWidgetState extends State<VideoplayWidget> {
  late VideoplayModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoplayModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<AppState>() 삭제 (Props 우선 사용)

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
      ),
      child: AppVideoPlayer(
        path: widget.videoUrl ?? '',
        videoType: VideoType.network,
        autoPlay: false,
        looping: true,
        showControls: true,
        allowFullScreen: true,
        allowPlaybackSpeedMenu: false,
      ),
    );
  }
}
