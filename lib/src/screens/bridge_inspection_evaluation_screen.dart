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
import 'package:kyoryo/src/models/photo_inspection_result.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/ui/selected_photo_check_mark.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

@RoutePage<PhotoInspectionResult>()
class BridgeInspectionEvaluationScreen extends ConsumerStatefulWidget {
  final InspectionPoint point;
  final PhotoInspectionResult photoInspectionResult;
  final InspectionPointReport? createdReport;

  const BridgeInspectionEvaluationScreen({
    super.key,
    required this.point,
    required this.photoInspectionResult,
    this.createdReport,
  });

  @override
  ConsumerState<BridgeInspectionEvaluationScreen> createState() =>
      BridgeInspectionEvaluationScreenState();
}

class BridgeInspectionEvaluationScreenState
    extends ConsumerState<BridgeInspectionEvaluationScreen> {
  late PhotoInspectionResult result;
  Future<void>? _pendingSubmission;
  InspectionPointReportStatus? _submissionType;
  String? _selectedCategory;
  String? _selectedHealthLevel;
  String? _selectedDamageType;

  late TextEditingController _textEditingController;
  late TextEditingController _damageCategoryController;
  late TextEditingController _damageTypeController;

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
    await _compressCapturedPhotos(result.newPhotoLocalPaths);
    await ref
        .read(bridgeInspectionProvider(widget.point.bridgeId!).notifier)
        .updateReport(
            report: widget.createdReport!.copyWith(status: status, metadata: {
              'damage_category': _selectedCategory ?? '',
              'damage_type': _selectedDamageType ?? '',
              'damage_level': _selectedHealthLevel ?? '',
              'remark': _textEditingController.text,
            }),
            capturedPhotoPaths: result.newPhotoLocalPaths,
            preferredPhotoPath: result.selectedPhotoPath,
            uploadedPhotos: result.uploadedPhotos);
  }

  Future<void> _createReport(InspectionPointReportStatus status) async {
    await _compressCapturedPhotos(result.newPhotoLocalPaths);
    if (result.isSkipped) status = InspectionPointReportStatus.skipped;
    await ref
        .read(bridgeInspectionProvider(widget.point.bridgeId!).notifier)
        .createReport(
            pointId: widget.point.id!,
            capturedPhotoPaths: result.newPhotoLocalPaths,
            preferredPhotoPath: result.selectedPhotoPath,
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
    final previousReport = ref
        .read(bridgeInspectionProvider(widget.point.bridgeId!).notifier)
        .findPreviousReportFromPoint(widget.point.id!);

    result = widget.photoInspectionResult;
    _textEditingController = TextEditingController();
    _damageCategoryController = TextEditingController();
    _damageTypeController = TextEditingController();


    _textEditingController.text = result.isSkipped
        ? result.skipReason.toString()
        : widget.createdReport?.metadata['remark'] ?? previousReport?.metadata['remark'] ?? '';

    _selectedCategory = widget.createdReport?.metadata['damage_category'] ??
        previousReport?.metadata['damage_category'];
    _selectedDamageType = widget.createdReport?.metadata['damage_type'] ??
        previousReport?.metadata['damage_type'];
    _selectedHealthLevel = widget.createdReport?.metadata['damage_level'] ??
        previousReport?.metadata['damage_level'];

    _damageCategoryController.text = _selectedCategory ?? '';
    _damageTypeController.text = _selectedDamageType ?? '';

  }

  @override
  Widget build(BuildContext context) {
    final damageTypes = ref.watch(damageTypesProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => didPop ? null : Navigator.pop(context, result),
      child: Scaffold(
          appBar: AppBar(title: Text(widget.point.spanName!), actions: [
            buildGoToPhotoSelectionButton(context),
          ]),
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
          }))),
    );
  }

  IconButton buildGoToPhotoSelectionButton(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.image),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          context
              .pushRoute<PhotoInspectionResult>(
                  BridgeInspectionPhotoSelectionRoute(
            photoInspectionResult: result,
            point: widget.point,
          ))
              .then((data) {
            if (data == null) {
              return;
            }

            setState(() {
              result = result.copyWith(
                  newPhotoLocalPaths: data.newPhotoLocalPaths,
                  uploadedPhotos: data.uploadedPhotos,
                  selectedPhotoPath: data.selectedPhotoPath);
            });
          });
        });
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
                          controller: _damageCategoryController,
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
                                    _damageTypeController.text = '';
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
                            child: DropdownMenu<String>(
                          controller: _damageTypeController,
                          initialSelection: _selectedDamageType,
                          label:
                              Text(AppLocalizations.of(context)!.damageDetails),
                          enabled: _selectedCategory != null,
                          expandedInsets: const EdgeInsets.all(0),
                          onSelected: (value) {
                            setState(() {
                              _selectedDamageType = value;
                            });
                          },
                          dropdownMenuEntries: damageTypes.hasValue
                              ? damageTypes.value!
                                  .where((type) =>
                                      type.category == _selectedCategory)
                                  .map((type) {
                                  return DropdownMenuEntry(
                                    value: type.nameJp,
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
                            final label = result.isSkipped
                                ? Text(AppLocalizations.of(context)!
                                    .skipEvaluation)
                                : Text(AppLocalizations.of(context)!
                                    .finishEvaluation);
                            final inspectionStatus = result.isSkipped
                                ? InspectionPointReportStatus.skipped
                                : InspectionPointReportStatus.finished;
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
                              label: label,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      submitInspection(inspectionStatus)
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
      return photo == result.selectedPhotoPath;
    } else {
      return photo.photoLink == result.selectedPhotoPath;
    }
  }

  Expanded buildPhotosCarousel(BuildContext context, Orientation orientation) {
    List<dynamic> combinedList = [
      ...result.uploadedPhotos,
      ...result.newPhotoLocalPaths,
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
                          child: SelectedPhotoCheckMark(
                              isSelected:
                                  isPhotoSelected(combinedList[index]))),
                    ],
                  );
                },
              );
            }).toList(),
          )),
        ]),
      ),
    );
  }
}
