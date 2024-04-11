import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';

class BridgeInspectionPhotoSelectionScreenArguments {
  final List<String> photoPaths;
  final InspectionPoint point;

  BridgeInspectionPhotoSelectionScreenArguments(
      {required this.photoPaths, required this.point});
}

class BridgeInspectionPhotoSelectionScreen extends StatefulWidget {
  final BridgeInspectionPhotoSelectionScreenArguments arguments;

  static const routeName = '/bridge-inspection-photo-selection';

  const BridgeInspectionPhotoSelectionScreen(
      {super.key, required this.arguments});

  @override
  State<BridgeInspectionPhotoSelectionScreen> createState() =>
      _BridgeInspectionPhotoSelectionScreenState();
}

class _BridgeInspectionPhotoSelectionScreenState
    extends State<BridgeInspectionPhotoSelectionScreen> {
  String? selectedPhotoPath;
  String? currentlyShowingPhoto;

  @override
  Widget build(BuildContext context) {
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
                    child: widget.arguments.point.photoUrl == null
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noPastPhotoFound))
                        : CachedNetworkImage(
                            imageUrl: widget.arguments.point.photoUrl!)),
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
                      child: widget.arguments.point.photoUrl == null
                          ? Center(
                              child: Text(AppLocalizations.of(context)!
                                  .noPastPhotoFound))
                          : CachedNetworkImage(
                              imageUrl: widget.arguments.point.photoUrl!,
                            ),
                    )),
              ],
            );
          }
        })),
      ),
    );
  }

  Expanded buildPhotosCarousel(BuildContext context, Orientation orientation) {
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
                    currentlyShowingPhoto = widget.arguments.photoPaths[index];
                  });
                },
                scrollDirection: Axis.horizontal,
              ),
              items: widget.arguments.photoPaths.mapIndexed((index, photo) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: [
                        Image(
                          image: FileImage(File(photo)),
                        ),
                        Positioned(
                            top: 2,
                            right: 2,
                            child: Icon(
                              Icons.check_circle,
                              color: widget.arguments.photoPaths[index] ==
                                      selectedPhotoPath
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
              onPressed: currentlyShowingPhoto == selectedPhotoPath
                  ? null
                  : () {
                      setState(() {
                        selectedPhotoPath = currentlyShowingPhoto;
                      });
                    },
              label: Text(AppLocalizations.of(context)!.setPreferredPhoto)),
        ]),
      ),
    );
  }
}
