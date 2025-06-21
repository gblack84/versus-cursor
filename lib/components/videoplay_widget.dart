import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_video_player.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: FlutterFlowVideoPlayer(
        path: '${FFAppState().UpLoadvideoA}',
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
