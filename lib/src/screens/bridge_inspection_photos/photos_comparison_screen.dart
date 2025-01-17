import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_photo_inspection_result.provider.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/ui/photo_sequence_number_mark.dart';

@RoutePage()
class BridgeInspectionPhotoComparisonScreen extends ConsumerWidget {
  final InspectionPoint point;

  const BridgeInspectionPhotoComparisonScreen({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoInspectionResult =
        ref.watch(currentPhotoInspectionResultProvider);

    final previousReport = ref
        .read(bridgeInspectionProvider(point.bridgeId).notifier)
        .findPreviousReportFromPoint(point.id!);

    final previousPhoto = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    buildPhotosCarousel(BuildContext context, Orientation orientation) {
      return CarouselSlider(
        options: CarouselOptions(
          viewportFraction: 1.0,
          initialPage: 0,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          reverse: false,
          scrollDirection: Axis.horizontal,
        ),
        items: photoInspectionResult.photos.map((photo) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: [
                  photo.localPath != null
                      ? Image.file(
                          File(photo.localPath!),
                          fit: BoxFit.cover,
                        )
                      : CachedNetworkImage(
                          imageUrl: photo.url!, fit: BoxFit.cover),
                  Positioned(
                      top: 2,
                      right: 2,
                      child: PhotoSequenceNumberMark(
                        number: photo.sequenceNumber,
                      )),
                ],
              );
            },
          );
        }).toList(),
      );
    }

    return OrientationBuilder(
      builder: ((context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: previousPhoto == null
                      ? Center(
                          child: Text(
                              AppLocalizations.of(context)!.noPastPhotoFound))
                      : CachedNetworkImage(imageUrl: previousPhoto.url!)),
              Expanded(child: buildPhotosCarousel(context, orientation)),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildPhotosCarousel(context, orientation),
                    ]),
              ),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: previousPhoto == null
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noPastPhotoFound))
                        : CachedNetworkImage(
                            imageUrl: previousPhoto.url!,
                          ),
                  )),
            ],
          );
        }
      }),
    );
  }
}
