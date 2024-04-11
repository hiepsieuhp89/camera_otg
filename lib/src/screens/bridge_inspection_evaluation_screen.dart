import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
import 'package:kyoryo/src/screens/bridge_inspection_photo_selection_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_screen.dart';

class BridgeInspectionEvaluationScreenArguments {
  final InspectionPoint point;
  final List<String> capturedPhotos;

  BridgeInspectionEvaluationScreenArguments({
    required this.point,
    required this.capturedPhotos,
  });
}

class BridgeInspectionEvaluationScreen extends ConsumerStatefulWidget {
  static const routeName = '/bridge-inspection-evaluation';
  final BridgeInspectionEvaluationScreenArguments arguments;

  const BridgeInspectionEvaluationScreen({super.key, required this.arguments});

  @override
  ConsumerState<BridgeInspectionEvaluationScreen> createState() =>
      BridgeInspectionEvaluationScreenState();
}

class BridgeInspectionEvaluationScreenState
    extends ConsumerState<BridgeInspectionEvaluationScreen> {
  Future<void>? _pendingSubmssion;
  String? _selectedCategory;
  String? _selectedHealthLevel;
  DamageType? _selectedDamageType;
  String? _preferredPhotoPath;
  late TextEditingController _textEditingController;

  Future<void> submitInspection() async {
    final reportSubmission = ref
        .read(
            bridgeInspectionProvider(widget.arguments.point.bridgeId!).notifier)
        .createReport(
            widget.arguments.point.id!,
            widget.arguments.capturedPhotos,
            {
              'damage_category': _selectedCategory ?? '',
              'damage_type': _selectedDamageType?.nameJp ?? '',
              'damage_level': _selectedHealthLevel ?? '',
              'remark': _textEditingController.text,
            },
            widget.arguments.capturedPhotos.indexOf(_preferredPhotoPath ?? ''))
        .then((_) {
      Navigator.popUntil(
          context, ModalRoute.withName(BridgeInspectionScreen.routeName));
    });

    setState(() {
      _pendingSubmssion = reportSubmission;
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final damageTypes = ref.watch(damageTypesProvider);

    return Scaffold(
        appBar: AppBar(
            title: Text(widget.arguments.point.name!),
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
        Navigator.of(context)
            .pushNamed(BridgeInspectionPhotoSelectionScreen.routeName,
                arguments: BridgeInspectionPhotoSelectionScreenArguments(
                    point: widget.arguments.point,
                    photoPaths: widget.arguments.capturedPhotos))
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
                          label: Text(AppLocalizations.of(context)!.damageType),
                          expandedInsets: const EdgeInsets.all(0),
                          onSelected: (category) {
                            setState(() {
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
                          label:
                              Text(AppLocalizations.of(context)!.damageDetails),
                          enabled: _selectedCategory != null,
                          expandedInsets: const EdgeInsets.all(0),
                          onSelected: (damageType) {
                            setState(() {
                              _selectedDamageType = damageType;
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
              FutureBuilder(
                  future: _pendingSubmssion,
                  builder: ((context, snapshot) {
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    return FilledButton.icon(
                      icon: isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.check),
                      label:
                          Text(AppLocalizations.of(context)!.finishEvaluation),
                      onPressed: isLoading
                          ? null
                          : () {
                              submitInspection().catchError((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(AppLocalizations.of(
                                                context)!
                                            .failedToCreateInspectionReport)));
                              });
                            },
                      style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(55)),
                    );
                  }))
            ],
          ),
        ));
  }

  Expanded buildPhotosCarousel(BuildContext context, Orientation orientation) {
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
            items: widget.arguments.capturedPhotos.mapIndexed((index, photo) {
              return Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: [
                      Positioned.fill(
                          child: Image(
                        image: FileImage(File(photo)),
                        fit: BoxFit.cover,
                      )),
                      Positioned(
                          top: 2,
                          right: 2,
                          child: Icon(
                            Icons.check_circle,
                            color: widget.arguments.capturedPhotos[index] ==
                                    _preferredPhotoPath
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
