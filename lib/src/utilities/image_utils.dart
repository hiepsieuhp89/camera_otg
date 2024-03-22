import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image/image.dart' as img;

Future<String> compressAndRotateImage(
    XFile capturedImage, Orientation? currentOrientation) async {
  File imageFile = File(capturedImage.path);
  Uint8List imageBytes = await imageFile.readAsBytes();
  img.Image? originalImage = img.decodeImage(imageBytes);

  if (originalImage != null && currentOrientation != null) {
    img.Image rotatedImage;
    switch (currentOrientation) {
      case Orientation.landscape:
        rotatedImage = originalImage;
        break;
      case Orientation.portrait:
        rotatedImage = img.copyRotate(originalImage, angle: 90);
        break;
    }

    Uint8List compressedImageBytes = img.encodeJpg(rotatedImage, quality: 85);

    await imageFile.writeAsBytes(compressedImageBytes);
  }

  return capturedImage.path;
}

void goToImagePreview(BuildContext context, String title, String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
            child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        )),
      ),
    ),
  );
}
