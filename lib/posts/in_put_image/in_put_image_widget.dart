import '/backend/firebase_storage/storage.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/core/app_widgets.dart';
import '/core/upload_data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'in_put_image_model.dart';
export 'in_put_image_model.dart';

class InPutImageWidget extends StatefulWidget {
  const InPutImageWidget({super.key});

  @override
  State<InPutImageWidget> createState() => _InPutImageWidgetState();
}

class _InPutImageWidgetState extends State<InPutImageWidget> {
  late InPutImageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InPutImageModel());

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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Color(0xFF14181B),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: AppButtonWidget(
                        onPressed: () async {
                          setState(() {
                            _model.isDataUploading_uploadImageG = false;
                            _model.uploadedLocalFiles_uploadImageG = [];
                            _model.uploadedFileUrls_uploadImageG = [];
                          });

                          final selectedMedia = await selectMedia(
                            maxWidth: 500.00,
                            maxHeight: 500.00,
                            imageQuality: 80,
                            mediaSource: MediaSource.photoGallery,
                            multiImage: true,
                          );
                          if (selectedMedia != null &&
                              selectedMedia.every((m) =>
                                  validateFileFormat(m.storagePath, context))) {
                            setState(() =>
                                _model.isDataUploading_uploadImageG = true);
                            var selectedUploadedFiles = <AppUploadedFile>[];

                            var downloadUrls = <String>[];
                            try {
                              selectedUploadedFiles = selectedMedia
                                  .map((m) => AppUploadedFile(
                                        name: m.storagePath.split('/').last,
                                        bytes: m.bytes,
                                        height: m.dimensions?.height,
                                        width: m.dimensions?.width,
                                        blurHash: m.blurHash,
                                      ))
                                  .toList();

                              downloadUrls = (await Future.wait(
                                selectedMedia.map(
                                  (m) async =>
                                      await uploadData(m.storagePath, m.bytes),
                                ),
                              ))
                                  .where((u) => u != null)
                                  .map((u) => u!)
                                  .toList();
                            } finally {
                              _model.isDataUploading_uploadImageG = false;
                            }
                            if (selectedUploadedFiles.length ==
                                    selectedMedia.length &&
                                downloadUrls.length == selectedMedia.length) {
                              setState(() {
                                _model.uploadedLocalFiles_uploadImageG =
                                    selectedUploadedFiles;
                                _model.uploadedFileUrls_uploadImageG =
                                    downloadUrls;
                              });
                            } else {
                              setState(() {});
                              return;
                            }
                          }

                          if (AppState().upLoadImageEditing == 0) {
                            AppState().addToUpLoadImageA(_model
                                .uploadedFileUrls_uploadImageG.firstOrNull!);
                            setState(() {});
                          } else {
                            AppState().addToUpLoadImageB(_model
                                .uploadedFileUrls_uploadImageG.firstOrNull!);
                            setState(() {});
                          }
                        },
                        text: AppLocalizations.of(context).getText(
                          'yaggfmwm' /* Gallary */,
                        ),
                        options: AppButtonOptions(
                          height: 40.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: AppTheme.of(context).primary,
                          textStyle:
                              AppTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: AppTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: AppButtonWidget(
                        onPressed: () async {
                          setState(() {
                            _model.isDataUploading_uploadImageC = false;
                            _model.uploadedLocalFile_uploadImageC =
                                AppUploadedFile(bytes: Uint8List.fromList([]));
                            _model.uploadedFileUrl_uploadImageC = '';
                          });

                          final selectedMedia = await selectMedia(
                            maxWidth: 500.00,
                            maxHeight: 500.00,
                            imageQuality: 80,
                            multiImage: false,
                          );
                          if (selectedMedia != null &&
                              selectedMedia.every((m) =>
                                  validateFileFormat(m.storagePath, context))) {
                            setState(() =>
                                _model.isDataUploading_uploadImageC = true);
                            var selectedUploadedFiles = <AppUploadedFile>[];

                            var downloadUrls = <String>[];
                            try {
                              selectedUploadedFiles = selectedMedia
                                  .map((m) => AppUploadedFile(
                                        name: m.storagePath.split('/').last,
                                        bytes: m.bytes,
                                        height: m.dimensions?.height,
                                        width: m.dimensions?.width,
                                        blurHash: m.blurHash,
                                      ))
                                  .toList();

                              downloadUrls = (await Future.wait(
                                selectedMedia.map(
                                  (m) async =>
                                      await uploadData(m.storagePath, m.bytes),
                                ),
                              ))
                                  .where((u) => u != null)
                                  .map((u) => u!)
                                  .toList();
                            } finally {
                              _model.isDataUploading_uploadImageC = false;
                            }
                            if (selectedUploadedFiles.length ==
                                    selectedMedia.length &&
                                downloadUrls.length == selectedMedia.length) {
                              setState(() {
                                _model.uploadedLocalFile_uploadImageC =
                                    selectedUploadedFiles.first;
                                _model.uploadedFileUrl_uploadImageC =
                                    downloadUrls.first;
                              });
                            } else {
                              setState(() {});
                              return;
                            }
                          }

                          if (AppState().upLoadImageEditing == 0) {
                            AppState().addToUpLoadImageA(_model
                                .uploadedFileUrls_uploadImageG.firstOrNull!);
                            setState(() {});
                          } else {
                            AppState().addToUpLoadImageB(_model
                                .uploadedFileUrls_uploadImageG.firstOrNull!);
                            setState(() {});
                          }
                        },
                        text: AppLocalizations.of(context).getText(
                          '63hun11y' /* Camera */,
                        ),
                        options: AppButtonOptions(
                          height: 40.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: AppTheme.of(context).primary,
                          textStyle:
                              AppTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: AppTheme.of(context)
                                          .titleSmall
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .titleSmall
                                          .fontStyle,
                                    ),
                                    color: Colors.white,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
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
            if (((AppState().upLoadImageEditing == 0) &&
                    (AppState().UpLoadImageA.isNotEmpty)) ||
                ((AppState().upLoadImageEditing == 1) &&
                    (AppState().UpLoadImageB.isNotEmpty)))
              Padding(
                padding: EdgeInsets.all(14.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    shape: BoxShape.rectangle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150.0,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color(0xFF14181B),
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              final inPutImagesB =
                                  (AppState().upLoadImageEditing == 0
                                          ? AppState().UpLoadImageA
                                          : AppState().UpLoadImageB)
                                      .toList();

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(inPutImagesB.length,
                                      (inPutImagesBIndex) {
                                    final inPutImagesBItem =
                                        inPutImagesB[inPutImagesBIndex];
                                    return Padding(
                                      padding: EdgeInsets.all(2.5),
                                      child: Container(
                                        width: 130.0,
                                        height: 140.0,
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.network(
                                                '${inPutImagesBItem}',
                                                width: 200.0,
                                                height: 200.0,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.87, -0.89),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await FirebaseStorage.instance
                                                      .refFromURL(
                                                          inPutImagesBItem)
                                                      .delete();
                                                  AppState()
                                                      .removeFromUpLoadImageA(
                                                          inPutImagesBItem);
                                                  AppState()
                                                      .removeFromUpLoadImageB(
                                                          inPutImagesBItem);
                                                  setState(() {});
                                                },
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .solidRectangleXmark,
                                                  color: Color(0xFFEF4040),
                                                  size: 24.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (((AppState().upLoadImageEditing == 0) &&
                    (AppState().UpLoadImageA.isNotEmpty)) ||
                ((AppState().upLoadImageEditing == 1) &&
                    (AppState().UpLoadImageB.isNotEmpty)))
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AppButtonWidget(
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      text: AppLocalizations.of(context).getText(
                        'bwlvl54v' /* Button */,
                      ),
                      options: AppButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: AppTheme.of(context).primary,
                        textStyle:
                            AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: AppTheme.of(context)
                                        .titleSmall
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .titleSmall
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context).getText(
                        'k73btvmc' /* Hello World */,
                      ),
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: AppTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: AppTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: AppTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
