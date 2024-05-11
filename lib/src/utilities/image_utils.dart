import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/ui/image_view_overlay.dart';
import 'package:image/image.dart' as img;
import 'package:kyoryo/src/ui/images_view_overlay.dart';

Future<void> compressAndRotateImage(String imagePath,
    {Orientation? currentOrientation, int quality = 85}) async {
  img.Image? image = await img.decodeImageFile(imagePath);

  if (image == null) {
    return;
  }

  if (currentOrientation != null) {
    switch (currentOrientation) {
      case Orientation.landscape:
        break;
      case Orientation.portrait:
        image = img.copyRotate(image, angle: 90);
        break;
    }
  }
  debugPrint('Original image size: ${image.length} bytes');

  Uint8List compressedImageBytes = img.encodeJpg(image, quality: quality);

  debugPrint('compressed image size: ${compressedImageBytes.length} bytes');

  await File(imagePath).writeAsBytes(compressedImageBytes);
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
