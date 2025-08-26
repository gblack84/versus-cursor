import '/core_exports.dart';
import '/app/state/app_state.dart';
// Previous: /core/app_theme.dart';
// Previous: /core/app_utils.dart';
// Previous: /core/app_video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/features/common/domain/models/videoplay_model.dart';
export '/features/common/domain/models/videoplay_model.dart';

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
        path: '${AppState().uploadVideoA}',
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
