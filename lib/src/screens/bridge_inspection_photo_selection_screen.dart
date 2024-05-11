import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';

class BridgeInspectionPhotoSelectionScreenArguments {
  final List<String> capturedPhotoPaths;
  final List<Photo> uploadedPhotos;
  final InspectionPoint point;

  BridgeInspectionPhotoSelectionScreenArguments(
      {required this.capturedPhotoPaths,
      required this.point,
      required this.uploadedPhotos});
}

class BridgeInspectionPhotoSelectionScreen extends ConsumerStatefulWidget {
  final BridgeInspectionPhotoSelectionScreenArguments arguments;

  static const routeName = '/bridge-inspection-photo-selection';

  const BridgeInspectionPhotoSelectionScreen(
      {super.key, required this.arguments});

  @override
  ConsumerState<BridgeInspectionPhotoSelectionScreen> createState() =>
      _BridgeInspectionPhotoSelectionScreenState();
}

class _BridgeInspectionPhotoSelectionScreenState
    extends ConsumerState<BridgeInspectionPhotoSelectionScreen> {
  String? selectedPhotoPath;
  dynamic currentlyShowingPhoto;

  @override
  void initState() {
    super.initState();
    currentlyShowingPhoto = widget.arguments.uploadedPhotos.isNotEmpty
        ? widget.arguments.uploadedPhotos.first
        : widget.arguments.capturedPhotoPaths.first;
  }

  @override
  Widget build(BuildContext context) {
    final previousReport = ref
        .read(
            bridgeInspectionProvider(widget.arguments.point.bridgeId!).notifier)
        .findPreviousReportFromPoint(widget.arguments.point.id!);

    final previousPhoto = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPoke) {
        if (!didPoke) {
          Navigator.pop(context, selectedPhotoPath);
        }
      },
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? AppBar(
                title: Text(AppLocalizations.of(context)!.pleaseSelectAPhoto),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, selectedPhotoPath),
                ),
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, selectedPhotoPath);
          },
          child: const Icon(Icons.check),
        ),
        body: OrientationBuilder(builder: ((context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: previousPhoto == null
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noPastPhotoFound))
                        : CachedNetworkImage(
                            imageUrl: previousPhoto.photoLink)),
                buildPhotosCarousel(context, orientation),
              ],
            );
          } else {
            return Row(
              children: [
                buildPhotosCarousel(context, orientation),
                Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: previousPhoto == null
                          ? Center(
                              child: Text(AppLocalizations.of(context)!
                                  .noPastPhotoFound))
                          : CachedNetworkImage(
                              imageUrl: previousPhoto.photoLink,
                            ),
                    )),
              ],
            );
          }
        })),
      ),
    );
  }

  bool isPhotoSelected(dynamic photo) {
    if (photo == null) {
      return false;
    }

    if (photo is String) {
      return photo == selectedPhotoPath;
    } else {
      return photo.photoLink == selectedPhotoPath;
    }
  }

  Expanded buildPhotosCarousel(BuildContext context, Orientation orientation) {
    List<dynamic> combinedList = [
      ...widget.arguments.uploadedPhotos,
      ...widget.arguments.capturedPhotoPaths,
    ];

    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(children: [
          if (orientation == Orientation.landscape)
            AppBar(
              title: Text(AppLocalizations.of(context)!.pleaseSelectAPhoto),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, selectedPhotoPath),
              ),
            ),
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                reverse: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentlyShowingPhoto = combinedList[index];
                  });
                },
                scrollDirection: Axis.horizontal,
              ),
              items: combinedList.mapIndexed((index, photo) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: [
                        combinedList[index] is String
                            ? Image.file(
                                File(combinedList[index]),
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: combinedList[index].photoLink,
                                fit: BoxFit.cover),
                        Positioned(
                            top: 2,
                            right: 2,
                            child: Icon(
                              Icons.check_circle,
                              color: isPhotoSelected(combinedList[index])
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                            )),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
          TextButton.icon(
              icon: const Icon(Icons.check_circle),
              onPressed: isPhotoSelected(currentlyShowingPhoto)
                  ? null
                  : () {
                      setState(() {
                        if (currentlyShowingPhoto is String) {
                          selectedPhotoPath = currentlyShowingPhoto;
                        } else if (currentlyShowingPhoto?.photoLink != null) {
                          selectedPhotoPath = currentlyShowingPhoto.photoLink;
                        }
                      });
                    },
              label: Text(AppLocalizations.of(context)!.setPreferredPhoto)),
        ]),
      ),
    );
  }
}
