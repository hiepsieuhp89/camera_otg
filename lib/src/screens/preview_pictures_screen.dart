import 'dart:io'; // Import dart:io for using File class

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/photo.dart';

class PreviewPicturesScreenArguments {
  final List<String> imagePaths;
  final List<Photo> photos;

  PreviewPicturesScreenArguments(
      {required this.imagePaths, required this.photos});
}

class PreviewPicturesScreenResult {
  final List<String> updatedImagePaths;
  final List<Photo> updatedUploadedPhotos;

  PreviewPicturesScreenResult(
      {required this.updatedImagePaths, required this.updatedUploadedPhotos});
}

class PreviewPicturesScreen extends StatefulWidget {
  final PreviewPicturesScreenArguments arguments;

  static const routeName = '/preview-pictures';

  const PreviewPicturesScreen({super.key, required this.arguments});

  @override
  State<PreviewPicturesScreen> createState() => _PreviewPicturesScreenState();
}

class _PreviewPicturesScreenState extends State<PreviewPicturesScreen> {
  late List<String> imagePaths;
  late List<Photo> photos;

  @override
  void initState() {
    super.initState();
    imagePaths = widget.arguments.imagePaths;
    photos = widget.arguments.photos;
  }

  void removeImage(String path) {
    setState(() {
      imagePaths.remove(path);
    });
  }

  void removePhoto(Photo photo) {
    setState(() {
      photos = photos.where((p) => p.id != photo.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPoke) {
        if (!didPoke) {
          Navigator.pop(
              context,
              PreviewPicturesScreenResult(
                  updatedImagePaths: imagePaths,
                  updatedUploadedPhotos: photos));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.previewPicturesTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(
                context,
                PreviewPicturesScreenResult(
                    updatedImagePaths: imagePaths,
                    updatedUploadedPhotos: photos)),
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            List<dynamic> combinedList = [...photos, ...imagePaths];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: combinedList.length,
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: combinedList[index] is String
                                ? FileImage(File(combinedList[index]))
                                    as ImageProvider
                                : CachedNetworkImageProvider(
                                    combinedList[index].photoLink),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: FloatingActionButton.small(
                          heroTag: 'image-$index',
                          onPressed: () => combinedList[index] is String
                              ? removeImage(combinedList[index])
                              : removePhoto(combinedList[index]),
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
