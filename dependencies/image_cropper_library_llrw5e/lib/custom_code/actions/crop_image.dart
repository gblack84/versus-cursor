// Automatic FlutterFlow imports
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io'; // Import dart:io for file operations
// Import the image_cropper and image_picker packages
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

Future<FFUploadedFile> cropImage(
  BuildContext context,
  double? imgWidth,
  double? imgHeight,
) async {
  final picker = ImagePicker();
  XFile? pickedImage = await picker.pickImage(source: ImageSource.gallery);

  if (pickedImage != null) {
    // Save the picked image locally
    final directory = await getApplicationDocumentsDirectory();
    String imagePath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';

    File localImageFile = File(imagePath);
    await localImageFile.writeAsBytes(await pickedImage.readAsBytes());

    // Use the image_cropper package to crop the image
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    if (croppedFile != null) {
      FFUploadedFile returnFile = FFUploadedFile(
        name: croppedFile.path.split('/').last,
        bytes: await croppedFile.readAsBytes(),
        height: imgWidth ?? 350.0,
        width: imgHeight ?? 350.0,
        blurHash: '',
      );

      print(returnFile.name);
      print(croppedFile.path);

      return returnFile;
    } else {
      throw Exception("Crop Image Error: Cropped file is null");
    }
  } else {
    throw Exception("Image Pick Error: Picked image is null");
  }
}
