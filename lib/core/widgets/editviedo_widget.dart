import '/core_exports.dart';
// Previous: /core/app_theme.dart';
// Previous: /core/app_utils.dart';
// Previous: /core/app_video_player.dart';
// Previous: /core/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'editviedo_provider.dart';
export 'editviedo_provider.dart';
export 'editviedo_state.dart';

class EditviedoWidget extends ConsumerStatefulWidget {
  const EditviedoWidget({super.key});

  @override
  ConsumerState<EditviedoWidget> createState() => _EditviedoWidgetState();
}

class _EditviedoWidgetState extends ConsumerState<EditviedoWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF81F3E5),
            ),
            child: AppVideoPlayer(
              path:
                  'https://assets.mixkit.co/videos/preview/mixkit-forest-stream-in-the-sunlight-529-large.mp4',
              videoType: VideoType.network,
              autoPlay: false,
              looping: true,
              showControls: true,
              allowFullScreen: true,
              allowPlaybackSpeedMenu: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF9F2929),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          AppLocalizations.of(context).getText(
                            '613h5dwl' /* Hello World */,
                          ),
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle:
                                      AppTheme.of(context).bodyMedium.fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight:
                                    AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                        Slider(
                          activeColor: AppTheme.of(context).primary,
                          inactiveColor: AppTheme.of(context).alternate,
                          min: 0.0,
                          max: 60.0,
                          value: ref.watch(editviedoProvider).sliderValue1 ??
                              ref.watch(editviedoProvider).startSec,
                          onChanged: (newValue) {
                            newValue =
                                double.parse(newValue.toStringAsFixed(2));
                            ref
                                .read(editviedoProvider.notifier)
                                .updateSlider1(newValue);
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: AppTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          AppLocalizations.of(context).getText(
                            'h9yoweew' /* Hello World */,
                          ),
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle:
                                      AppTheme.of(context).bodyMedium.fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontWeight:
                                    AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                        ),
                        Slider(
                          activeColor: AppTheme.of(context).primary,
                          inactiveColor: AppTheme.of(context).alternate,
                          min: 0.0,
                          max: 60.0,
                          value: ref.watch(editviedoProvider).sliderValue2 ??
                              ref.watch(editviedoProvider).endSec,
                          onChanged: (newValue) {
                            newValue =
                                double.parse(newValue.toStringAsFixed(2));
                            ref
                                .read(editviedoProvider.notifier)
                                .updateSlider2(newValue);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: AppButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: AppLocalizations.of(context).getText(
                        'g405hkr8' /* upload */,
                      ),
                      options: AppButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight:
                                    AppTheme.of(context).titleSmall.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).titleSmall.fontStyle,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight:
                                  AppTheme.of(context).titleSmall.fontWeight,
                              fontStyle:
                                  AppTheme.of(context).titleSmall.fontStyle,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: AppButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: AppLocalizations.of(context).getText(
                        'r3qip94t' /* cancle */,
                      ),
                      options: AppButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).titleSmall.override(
                              font: GoogleFonts.plusJakartaSans(
                                fontWeight:
                                    AppTheme.of(context).titleSmall.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).titleSmall.fontStyle,
                              ),
                              color: Colors.white,
                              letterSpacing: 0.0,
                              fontWeight:
                                  AppTheme.of(context).titleSmall.fontWeight,
                              fontStyle:
                                  AppTheme.of(context).titleSmall.fontStyle,
                            ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
