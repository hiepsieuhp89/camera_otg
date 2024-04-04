import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/ui/image_view_overlay.dart';
import 'package:image/image.dart' as img;
import 'package:kyoryo/src/ui/images_view_overlay.dart';

Future<String> compressAndRotateImage(XFile capturedImage,
    {Orientation? currentOrientation, int quality = 85}) async {
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

    Uint8List compressedImageBytes =
        img.encodeJpg(rotatedImage, quality: quality);

    await imageFile.writeAsBytes(compressedImageBytes);
  }

  return capturedImage.path;
}

void viewImage(BuildContext context,
    {required String imageUrl, Marking? marking}) {
  Navigator.push(
      context, ImageViewOverlay(imageUrl: imageUrl, marking: marking));
}

void viewImages(BuildContext context, List<String> imageUrls, int initialImage,
    Map<int, Marking>? markings) {
  Navigator.push(
      context,
      ImagesViewOverlay(imageUrls,
          initialPage: initialImage, markings: markings ?? {}));
}
