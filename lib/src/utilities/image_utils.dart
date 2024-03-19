import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_view/photo_view.dart';

Future<XFile?> compressImage(String path, int quality) async {
  final newPath = "${path.substring(0, path.lastIndexOf("."))}_compressed.jpg";

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    path,
    newPath,
    quality: quality,
  );

  return compressedFile;
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
