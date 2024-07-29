import 'dart:io'; // Import dart:io for using File class

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class PreviewPicturesScreenResult {
  final List<String> updatedImagePaths;
  final List<Photo> updatedUploadedPhotos;

  PreviewPicturesScreenResult(
      {required this.updatedImagePaths, required this.updatedUploadedPhotos});
}

@RoutePage<PreviewPicturesScreenResult>()
class PreviewPicturesScreen extends StatefulWidget {
  final List<String> imagePaths;
  final List<Photo> photos;

  const PreviewPicturesScreen(
      {super.key, required this.imagePaths, required this.photos});

  @override
  State<PreviewPicturesScreen> createState() => _PreviewPicturesScreenState();
}

class _PreviewPicturesScreenState extends State<PreviewPicturesScreen> {
  late List<String> imagePaths;
  late List<Photo> photos;

  @override
  void initState() {
    super.initState();
    imagePaths = widget.imagePaths;
    photos = widget.photos;
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
          AutoRouter.of(context).maybePop<PreviewPicturesScreenResult>(
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: combinedList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      combinedList[index] is String
                          ? Image.file(File(combinedList[index]))
                          : CachedNetworkImage(
                              imageUrl: combinedList[index].photoLink),
                      Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black54),
                            child: IconButton(
                                icon: const Icon(
                                  Icons.open_in_full,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  viewImage(context,
                                      imageUrl: combinedList[index] is String
                                          ? combinedList[index]
                                          : combinedList[index].photoLink);
                                }),
                          )),
                      Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black54),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => combinedList[index] is String
                                  ? removeImage(combinedList[index])
                                  : removePhoto(combinedList[index]),
                            ),
                          )),
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
