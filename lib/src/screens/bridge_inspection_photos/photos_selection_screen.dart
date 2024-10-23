import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:kyoryo/src/providers/current_photo_inspection_result.provider.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

@RoutePage()
class BridgeInspectionPhotoSelectionScreen extends ConsumerWidget {
  const BridgeInspectionPhotoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(currentPhotoInspectionResultProvider);

    Stack buildPhoto(
        {required InspectionPointReportPhoto photo,
        required BuildContext context,
        required int index}) {
      Widget image;

      if (photo.localPath != null) {
        image = Image.file(File(photo.localPath!));
      } else if (photo.url != null) {
        image = CachedNetworkImage(imageUrl: photo.url!);
      } else {
        throw ArgumentError('Either localPath or url must be provided');
      }

      return Stack(
        children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.decelerate,
              decoration: BoxDecoration(
                border: photo.sequenceNumber != null
                    ? Border.all(
                        color: Colors.grey[200]!,
                        width: 12,
                      )
                    : const Border(),
              ),
              child: photo.sequenceNumber == null
                  ? SizedBox(width: 300, height: 300, child: image)
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0,
                          color: Colors.grey[200]!,
                        ),
                        color: Colors.grey[200]!,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        child: SizedBox(width: 300, height: 300, child: image),
                      ),
                    )),
          if (photo.sequenceNumber != null)
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200]!,
                  ),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Center(
                      child: Text(
                        photo.sequenceNumber.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black26),
                child: IconButton(
                    icon: const Icon(
                      Icons.open_in_full,
                      color: Colors.white,
                      size: 14,
                    ),
                    onPressed: () {
                      viewImage(context,
                          imageUrl: photo.localPath ?? photo.url!);
                    }),
              )),
          Positioned(
              bottom: 2,
              left: 2,
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black26),
                child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 14,
                    ),
                    onPressed: () {
                      ref
                          .read(currentPhotoInspectionResultProvider.notifier)
                          .removePhoto(index);
                    }),
              ))
        ],
      );
    }

    return OrientationBuilder(
      builder: ((context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: GridView.builder(
                itemCount: result.photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 150,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentPhotoInspectionResultProvider.notifier)
                          .selectPhoto(index);
                    },
                    child: buildPhoto(
                      context: context,
                      photo: result.photos[index],
                      index: index,
                    ),
                  );
                },
              )),
            ],
          );
        } else {
          return Row(
            children: [
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        toolbarHeight: 48,
                        title: Text(
                          AppLocalizations.of(context)!.selectAndOrderPhotos,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Flexible(
                        child: GridView.builder(
                          itemCount: result.photos.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisExtent: 150,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(currentPhotoInspectionResultProvider
                                        .notifier)
                                    .selectPhoto(index);
                              },
                              child: buildPhoto(
                                context: context,
                                photo: result.photos[index],
                                index: index,
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  )),
            ],
          );
        }
      }),
    );
  }
}
