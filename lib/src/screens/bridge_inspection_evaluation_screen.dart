import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

@RoutePage()
class BridgeInspectionEvaluationScreen extends ConsumerStatefulWidget {
  final InspectionPoint point;
  final List<String> capturedPhotos;
  final List<Photo> uploadedPhotos;
  final InspectionPointReport? createdReport;

  const BridgeInspectionEvaluationScreen(
      {super.key,
      required this.point,
      required this.capturedPhotos,
      required this.uploadedPhotos,
      this.createdReport});

  @override
  ConsumerState<BridgeInspectionEvaluationScreen> createState() =>
      BridgeInspectionEvaluationScreenState();
}

class BridgeInspectionEvaluationScreenState
    extends ConsumerState<BridgeInspectionEvaluationScreen> {
  Future<void>? _pendingSubmission;
  InspectionPointReportStatus? _submissionType;
  String? _selectedCategory;
  String? _selectedHealthLevel;
  String? _selectedDamageType;
  String? _preferredPhotoPath;

  late TextEditingController _textEditingController;

  Future<void> submitInspection(InspectionPointReportStatus status) async {
    final reportSubmission = (widget.createdReport != null
            ? _updateReport(status)
            : _createReport(status))
        .then((_) {
      context.router.popUntilRouteWithName(BridgeInspectionRoute.name);
    });

    setState(() {
      _submissionType = status;
      _pendingSubmission = reportSubmission;
    });
  }

  Future<void> _compressCapturedPhotos(List<String> photoPaths) async {
    await Future.wait(photoPaths.map((photoPath) async {
      return await compressImage(photoPath);
    }));
  }

  Future<void> _updateReport(InspectionPointReportStatus status) async {
    if (widget.createdReport == null) {
      throw Exception('Report is not created yet');
    }
    await _compressCapturedPhotos(widget.capturedPhotos);
    await ref
        .read(bridgeInspectionProvider(widget.point.bridgeId!).notifier)
        .updateReport(
            report: widget.createdReport!.copyWith(status: status, metadata: {
              'damage_category': _selectedCategory ?? '',
              'damage_type': _selectedDamageType ?? '',
              'damage_level': _selectedHealthLevel ?? '',
              'remark': _textEditingController.text,
            }),
            capturedPhotoPaths: widget.capturedPhotos,
            preferredPhotoPath: _preferredPhotoPath,
            uploadedPhotos: widget.uploadedPhotos);
  }

  Future<void> _createReport(InspectionPointReportStatus status) async {
    await _compressCapturedPhotos(widget.capturedPhotos);
    await ref
        .read(bridgeInspectionProvider(widget.point.bridgeId!).notifier)
        .createReport(
            pointId: widget.point.id!,
            capturedPhotoPaths: widget.capturedPhotos,
            preferredPhotoPath: _preferredPhotoPath,
            status: status,
            metadata: {
          'damage_category': _selectedCategory ?? '',
          'damage_type': _selectedDamageType ?? '',
          'damage_level': _selectedHealthLevel ?? '',
          'remark': _textEditingController.text,
        });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();

    _textEditingController.text =
        widget.createdReport?.metadata['remark'] ?? '';
    _selectedCategory = widget.createdReport?.metadata['damage_category'];
    _selectedDamageType = widget.createdReport?.metadata['damage_type'];
    _selectedHealthLevel = widget.createdReport?.metadata['damage_level'];
  }

  @override
  Widget build(BuildContext context) {
    final damageTypes = ref.watch(damageTypesProvider);

    return Scaffold(
        appBar: AppBar(
            title: Text(widget.point.name!),
            actions: MediaQuery.of(context).orientation == Orientation.landscape
                ? [
                    buildGoToPhotoSelectionButton(context),
                    const SizedBox(width: 12),
                  ]
                : null),
        body: OrientationBuilder(builder: ((context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPhotosCarousel(context, orientation),
                buildEvaluationForm(context, damageTypes),
              ],
            );
          } else {
            return Row(
              children: [
                buildPhotosCarousel(context, orientation),
                buildEvaluationForm(context, damageTypes),
              ],
            );
          }
        })));
  }

  OutlinedButton buildGoToPhotoSelectionButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        context
            .pushRoute(BridgeInspectionPhotoSelectionRoute(
                capturedPhotoPaths: widget.capturedPhotos,
                point: widget.point,
                uploadedPhotos: widget.uploadedPhotos))
            .then((selectedPhotoPath) {
          setState(() {
            _preferredPhotoPath = selectedPhotoPath as String?;
          });
        });
      },
      icon: const Icon(Icons.image),
      label: Text(AppLocalizations.of(context)!.goToPhotoSelectionButton),
    );
  }

  Expanded buildEvaluationForm(
      BuildContext context, AsyncValue<List<DamageType>> damageTypes) {
    return Expanded(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: DropdownMenu<String>(
                          initialSelection: _selectedCategory,
                          label: Text(AppLocalizations.of(context)!.damageType),
                          expandedInsets: const EdgeInsets.all(0),
                          onSelected: (category) {
                            category == 'NON'
                                ? setState(() {
                                    _selectedCategory = category;
                                    _selectedDamageType = 'NON';
                                    _selectedHealthLevel = 'a';
                                  })
                                : setState(() {
                                    _selectedCategory = category;
                                    _selectedDamageType = null;
                                  });
                          },
                          dropdownMenuEntries: damageTypes.hasValue
                              ? damageTypes.value!
                                  .map((type) => type.category)
                                  .toSet()
                                  .map((category) {
                                  return DropdownMenuEntry(
                                    value: category,
                                    label: category,
                                  );
                                }).toList()
                              : const [],
                        )),
                        const SizedBox(width: 8),
                        Expanded(
                            child: DropdownMenu<DamageType>(
                          initialSelection: damageTypes.hasValue
                              ? damageTypes.value!.firstWhereOrNull(
                                  (type) => type.nameJp == _selectedDamageType)
                              : null,
                          label:
                              Text(AppLocalizations.of(context)!.damageDetails),
                          enabled: _selectedCategory != null,
                          expandedInsets: const EdgeInsets.all(0),
                          onSelected: (damageType) {
                            setState(() {
                              _selectedDamageType = damageType?.nameJp;
                            });
                          },
                          dropdownMenuEntries: damageTypes.hasValue
                              ? damageTypes.value!
                                  .where((type) =>
                                      type.category == _selectedCategory)
                                  .map((type) {
                                  return DropdownMenuEntry(
                                    value: type,
                                    label: type.nameJp,
                                  );
                                }).toList()
                              : const [],
                        ))
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        DropdownMenu<String>(
                          initialSelection: _selectedHealthLevel,
                          label: Text(AppLocalizations.of(context)!.damage),
                          onSelected: (healthLevel) {
                            setState(() {
                              _selectedHealthLevel = healthLevel;
                            });
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 'a', label: 'a'),
                            DropdownMenuEntry(value: 'b', label: 'b'),
                            DropdownMenuEntry(value: 'c', label: 'c'),
                            DropdownMenuEntry(value: 'd', label: 'd'),
                            DropdownMenuEntry(value: 'e', label: 'e'),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: TextField(
                                controller: _textEditingController,
                                decoration: InputDecoration(
                                  label: Text(
                                      AppLocalizations.of(context)!.remark),
                                  border: const OutlineInputBorder(),
                                )))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: FutureBuilder(
                          future: _pendingSubmission,
                          builder: ((context, snapshot) {
                            final isLoading = snapshot.connectionState ==
                                ConnectionState.waiting;

                            return FilledButton.icon(
                              icon: isLoading &&
                                      _submissionType ==
                                          InspectionPointReportStatus.pending
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Icon(Icons.timer),
                              label: Text(
                                  AppLocalizations.of(context)!.holdButton),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      submitInspection(
                                              InspectionPointReportStatus
                                                  .pending)
                                          .catchError((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(AppLocalizations
                                                        .of(context)!
                                                    .failedToCreateInspectionReport)));
                                      });
                                    },
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(55),
                                  backgroundColor: Colors.orange),
                            );
                          }))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: FutureBuilder(
                          future: _pendingSubmission,
                          builder: ((context, snapshot) {
                            final isLoading = snapshot.connectionState ==
                                ConnectionState.waiting;

                            return FilledButton.icon(
                              icon: isLoading &&
                                      _submissionType ==
                                          InspectionPointReportStatus.finished
                                  ? Container(
                                      width: 24,
                                      height: 24,
                                      padding: const EdgeInsets.all(2.0),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(AppLocalizations.of(context)!
                                  .finishEvaluation),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      submitInspection(
                                              InspectionPointReportStatus
                                                  .finished)
                                          .catchError((_) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(AppLocalizations
                                                        .of(context)!
                                                    .failedToCreateInspectionReport)));
                                      });
                                    },
                              style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(55)),
                            );
                          })))
                ],
              )
            ],
          ),
        ));
  }

  bool isPhotoSelected(dynamic photo) {
    if (photo is String) {
      return photo == _preferredPhotoPath;
    } else {
      return photo.photoLink == _preferredPhotoPath;
    }
  }

  Expanded buildPhotosCarousel(BuildContext context, Orientation orientation) {
    List<dynamic> combinedList = [
      ...widget.uploadedPhotos,
      ...widget.capturedPhotos,
    ];

    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Expanded(
              child: CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: false,
              reverse: false,
              enlargeCenterPage: true,
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
                              fit: BoxFit.fill,
                            )
                          : CachedNetworkImage(
                              imageUrl: combinedList[index].photoLink,
                              fit: BoxFit.fill),
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
          )),
          if (orientation == Orientation.portrait)
            buildGoToPhotoSelectionButton(context)
        ]),
      ),
    );
  }
}
