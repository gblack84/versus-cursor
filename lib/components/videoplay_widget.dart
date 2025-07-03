import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/core/app_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    context.watch<AppState>();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
      ),
      child: AppVideoPlayer(
        path: '${AppState().UpLoadvideoA}',
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
