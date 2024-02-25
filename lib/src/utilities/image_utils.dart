import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<XFile?> compressImage(String path, int quality) async {
  final newPath = "${path.substring(0, path.lastIndexOf("."))}_compressed.jpg";

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    path,
    newPath,
    quality: quality,
  );

  return compressedFile;
}
