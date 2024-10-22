import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo_inspection_result.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/ui/selected_photo_check_mark.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

@RoutePage()
class BridgeInspectionPhotoSelectionScreen extends ConsumerStatefulWidget {
  final PhotoInspectionResult photoInspectionResult;
  final InspectionPoint point;
  final InspectionPointReport? createdReport;

  const BridgeInspectionPhotoSelectionScreen({
    super.key,
    required this.photoInspectionResult,
    required this.point,
    this.createdReport,
  });

  @override
  ConsumerState<BridgeInspectionPhotoSelectionScreen> createState() =>
      _BridgeInspectionPhotoSelectionScreenState();
}

class _BridgeInspectionPhotoSelectionScreenState
    extends ConsumerState<BridgeInspectionPhotoSelectionScreen> {
  final CarouselSliderController carouselController =
      CarouselSliderController();
  late PhotoInspectionResult result;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.photoInspectionResult.selectedPhotoPath.isEmpty) {
      result = widget.photoInspectionResult.copyWith(
          selectedPhotoPath:
              widget.photoInspectionResult.uploadedPhotos.firstOrNull?.url ??
                  widget.photoInspectionResult.newPhotoLocalPaths.firstOrNull ??
                  '');
    } else {
      result = widget.photoInspectionResult.copyWith();
    }
  }

  @override
  Widget build(BuildContext context) {
    final previousReport = ref
        .read(bridgeInspectionProvider(widget.point.bridgeId!).notifier)
        .findPreviousReportFromPoint(widget.point.id!);

    final previousPhoto = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPope, _) {
        if (!didPope) {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? AppBar(
                title: Text(AppLocalizations.of(context)!.pleaseSelectAPhoto),
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.router.replace(BridgeInspectionEvaluationRoute(
                point: widget.point,
                photoInspectionResult: result,
                createdReport: widget.createdReport));
          },
          child: const Icon(Icons.check),
        ),
        body: OrientationBuilder(builder: ((context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPhotosCarousel(context, orientation),
                Expanded(
                    child: previousPhoto == null
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noPastPhotoFound))
                        : CachedNetworkImage(imageUrl: previousPhoto.url)),
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
                              imageUrl: previousPhoto.url,
                            ),
                    )),
              ],
            );
          }
        })),
      ),
    );
  }

  void removeCurrentPhoto() {
    result.removePhoto(currentIndex);

    if (currentIndex >= result.allPhotos.length) {
      currentIndex = result.allPhotos.length - 1;
    }

    setState(() {});
  }

  void viewCurrentPhoto() {
    viewImage(context,
        imageUrl: result.allPhotos[currentIndex] is String
            ? result.allPhotos[currentIndex]
            : result.allPhotos[currentIndex].url);
  }

  void selectCurrentPhoto() {
    if (result.allPhotos[currentIndex] is String) {
      result.selectedPhotoPath = result.allPhotos[currentIndex];
    } else if (result.allPhotos[currentIndex]?.url != null) {
      result.selectedPhotoPath = result.allPhotos[currentIndex].url;
    }

    setState(() {});
  }

  Expanded buildPhotosCarousel(BuildContext context, Orientation orientation) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(children: [
          if (orientation == Orientation.landscape)
            AppBar(
              title: Text(AppLocalizations.of(context)!.pleaseSelectAPhoto),
            ),
          Expanded(
            child: CarouselSlider(
              carouselController: carouselController,
              options: CarouselOptions(
                viewportFraction: 1.0,
                initialPage: 0,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                reverse: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                scrollDirection: Axis.horizontal,
              ),
              items: result.allPhotos.mapIndexed((index, photo) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: [
                        result.allPhotos[index] is String
                            ? Image.file(
                                File(result.allPhotos[index]),
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: result.allPhotos[index].url,
                                fit: BoxFit.cover),
                        Positioned(
                            top: 2,
                            right: 2,
                            child: SelectedPhotoCheckMark(
                              isSelected: result.isPhotoSelected(
                                  result.allPhotos[index] is String &&
                                          result.allPhotos[index] != null
                                      ? result.allPhotos[index]
                                      : result.allPhotos[index].url),
                            )),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.open_in_full,
                    ),
                    onPressed: currentIndex < 0 ? null : viewCurrentPhoto),
                IconButton(
                  icon: const Icon(Icons.check_circle),
                  onPressed: currentIndex < 0 ||
                          result.isPhotoSelected(
                              result.allPhotos[currentIndex] is String
                                  ? result.allPhotos[currentIndex]
                                  : result.allPhotos[currentIndex].url)
                      ? null
                      : selectCurrentPhoto,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: currentIndex < 0 ? null : removeCurrentPhoto,
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
