import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/damage_type.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
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
  late TextEditingController _textEditingController;

  Future<void> submitInspection() async {
    final reportSubmission = ref
        .read(
            bridgeInspectionProvider(widget.arguments.point.bridgeId!).notifier)
        .createReport(
            widget.arguments.point.id!, widget.arguments.capturedPhotos, {
      'damage_category': _selectedCategory ?? '',
      'damage_type': _selectedDamageType?.nameJp ?? '',
      'health_level': _selectedHealthLevel ?? '',
      'remark': _textEditingController.text,
    }).then((_) {
      ref.invalidate(
          inspectionPointsProvider(widget.arguments.point.bridgeId!));

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
        appBar: AppBar(title: Text(widget.arguments.point.name!)),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  // Be cautious with this approach; use it as a last resort
                  // The height should be at least as tall as the screen to ensure scrolling works as expected
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Stack(children: [
                          Column(children: [
                            Row(children: [
                              Text(
                                AppLocalizations.of(context)!
                                    .currentInspectionPhoto,
                                style: Theme.of(context).textTheme.labelLarge,
                              )
                            ]),
                            const SizedBox(height: 8),
                            Expanded(
                                child: CarouselSlider(
                              options: CarouselOptions(
                                viewportFraction: 0.6,
                                initialPage: 0,
                                enableInfiniteScroll: false,
                                reverse: false,
                                enlargeCenterPage: true,
                                onPageChanged: (index, reason) {},
                                scrollDirection: Axis.horizontal,
                              ),
                              items:
                                  widget.arguments.capturedPhotos.map((photo) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Image(
                                      image: FileImage(File(photo)),
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              }).toList(),
                            )),
                          ]),
                          const Positioned(
                            right: 0,
                            bottom: 0,
                            child: Icon(Icons.check,
                                color: Colors.green, size: 90),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.assessment,
                                    style:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                      child: DropdownMenu<String>(
                                    label: Text(AppLocalizations.of(context)!
                                        .damageType),
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
                                    label: Text(AppLocalizations.of(context)!
                                        .damageDetails),
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
                                                type.category ==
                                                _selectedCategory)
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
                              DropdownMenu<String>(
                                label:
                                    Text(AppLocalizations.of(context)!.damage),
                                expandedInsets: const EdgeInsets.all(0),
                                onSelected: (healthLevel) {
                                  setState(() {
                                    _selectedHealthLevel = healthLevel;
                                  });
                                },
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry(value: 'A', label: 'A'),
                                  DropdownMenuEntry(value: 'B', label: 'B'),
                                  DropdownMenuEntry(value: 'C', label: 'C'),
                                  DropdownMenuEntry(value: 'D', label: 'D'),
                                  DropdownMenuEntry(value: 'E', label: 'E'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                  controller: _textEditingController,
                                  decoration: InputDecoration(
                                    label: Text(
                                        AppLocalizations.of(context)!.remark),
                                    border: const OutlineInputBorder(),
                                  ))
                            ],
                          )),
                      const SizedBox(height: 16),
                      FutureBuilder(
                          future: _pendingSubmssion,
                          builder: ((context, snapshot) {
                            final isLoading = snapshot.connectionState ==
                                ConnectionState.waiting;

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
                              label: Text(AppLocalizations.of(context)!
                                  .finishEvaluation),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      submitInspection().catchError((_) {
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
                          }))
                    ],
                  ),
                ))));
  }
}
