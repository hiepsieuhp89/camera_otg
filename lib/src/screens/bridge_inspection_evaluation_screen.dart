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
import 'package:kyoryo/src/providers/current_photo_inspection_result.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/ui/photo_sequence_number_mark.dart';

@RoutePage()
class BridgeInspectionEvaluationScreen extends ConsumerStatefulWidget {
  final InspectionPoint point;

  const BridgeInspectionEvaluationScreen({
    super.key,
    required this.point,
  });

  @override
  ConsumerState<BridgeInspectionEvaluationScreen> createState() =>
      BridgeInspectionEvaluationScreenState();
}

class BridgeInspectionEvaluationScreenState
    extends ConsumerState<BridgeInspectionEvaluationScreen> {
  late PhotoInspectionResult result;
  String? _selectedCategory;
  String? _selectedHealthLevel;
  String? _selectedDamageType;
  late String _initialDamageType;
  late String _initialDamageCategory;
  late List<String> _damageTypeOptions;

  late TextEditingController _textEditingController;
  late TextEditingController _damageCategoryController;
  late TextEditingController _damageTypeController;

  Future<void> submitInspection(InspectionPointReportStatus status) async {
    final router = AutoRouter.of(context);
    final activeReport = ref
        .read(bridgeInspectionProvider(widget.point.bridgeId).notifier)
        .findActiveReportFromPoint(widget.point.id!);

    showMessageFailure() {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.failedToCreateInspectionReport)));
    }

    (activeReport != null
            ? _updateReport(activeReport, status)
            : _createReport(status).catchError((_) {
                showMessageFailure();
              }))
        .then((_) {
      router.popUntil((route) {
        return [BridgeInspectionTabRoute.name, DiagramInspectionRoute.name]
            .contains(route.settings.name);
      });
    });
  }

  Future<void> _updateReport(
      InspectionPointReport report, InspectionPointReportStatus status) async {
    ref
        .read(bridgeInspectionProvider(widget.point.bridgeId).notifier)
        .updateReport(
          report: report.copyWith(
              status: status,
              metadata: {
                'damage_category': _selectedCategory ?? '',
                'damage_type': _selectedDamageType ?? '',
                'damage_level': _selectedHealthLevel ?? '',
                'remark': _textEditingController.text,
              },
              photos: result.photos),
        );
  }

  Future<void> _createReport(InspectionPointReportStatus status) async {
    ref
        .read(bridgeInspectionProvider(widget.point.bridgeId).notifier)
        .createReport(
            report: InspectionPointReport(
                inspectionPointId: widget.point.id!,
                status: status,
                metadata: {
                  'damage_category': _selectedCategory ?? '',
                  'damage_type': _selectedDamageType ?? '',
                  'damage_level': _selectedHealthLevel ?? '',
                  'remark': _textEditingController.text,
                },
                photos: result.photos));
  }

  @override
  void initState() {
    super.initState();
    final previousReport = ref
        .read(bridgeInspectionProvider(widget.point.bridgeId).notifier)
        .findPreviousReportFromPoint(widget.point.id!);

    final activeReport = ref
        .read(bridgeInspectionProvider(widget.point.bridgeId).notifier)
        .findActiveReportFromPoint(widget.point.id!);

    result = ref.read(currentPhotoInspectionResultProvider);
    _textEditingController = TextEditingController();
    _damageCategoryController = TextEditingController();
    _damageTypeController = TextEditingController();

    if (activeReport != null) {
      _textEditingController.text = result.isSkipped
          ? result.skipReason.toString()
          : activeReport.metadata['remark'] ?? '';
      _selectedCategory = activeReport.metadata['damage_category'];
      _selectedDamageType = activeReport.metadata['damage_type'];
      _selectedHealthLevel = activeReport.metadata['damage_level'];
    } else {
      _textEditingController.text = result.isSkipped
          ? result.skipReason.toString()
          : previousReport?.metadata['remark'] ?? '';
      _selectedCategory = previousReport?.metadata['damage_category'];
      _selectedDamageType = previousReport?.metadata['damage_type'];
      _selectedHealthLevel = previousReport?.metadata['damage_level'];
    }

    _initialDamageType = _selectedDamageType ?? '';
    _initialDamageCategory = _selectedCategory ?? '';
    _damageTypeOptions = _selectedCategory != null
        ? ref
            .read(damageTypesProvider)
            .value!
            .where((type) => type.category == _selectedCategory)
            .map((type) => type.nameJp)
            .toList()
        : [_initialDamageType];
  }

  @override
  Widget build(BuildContext context) {
    final damageTypes = ref.watch(damageTypesProvider);

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: orientation == Orientation.portrait
                ? AppBar(title: Text(widget.point.spanName ?? ''), actions: [
                    buildGoToPhotoSelectionButton(context),
                  ])
                : null,
            body: orientation == Orientation.portrait
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildPhotosCarousel(context, orientation),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: buildEvaluationForm(
                            context, damageTypes, orientation),
                      )),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: buildPhotosCarousel(context, orientation),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: buildEvaluationForm(
                            context, damageTypes, orientation),
                      )),
                    ],
                  ));
      },
    );
  }

  IconButton buildGoToPhotoSelectionButton(BuildContext context) {
    onButtonPressed() {
      context.router
          .push<PhotoInspectionResult>(
              BridgeInspectionPhotosTabRoute(point: widget.point))
          .then((data) {
        if (data == null) {
          return;
        }

        setState(() {
          result = result.copyWith();
        });
      });
    }

    return IconButton(
        icon: const Icon(Icons.image),
        color: Theme.of(context).primaryColor,
        onPressed: !result.isSkipped ? onButtonPressed : null);
  }

  buildEvaluationForm(BuildContext context,
      AsyncValue<List<DamageType>> damageTypes, Orientation orientation) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: DropdownMenu<String>(
                    initialSelection: _initialDamageCategory,
                    controller: _damageCategoryController,
                    label: Text(AppLocalizations.of(context)!.damageType),
                    expandedInsets: const EdgeInsets.all(0),
                    onSelected: (category) {
                      setState(() {
                        _selectedCategory = category;

                        _damageTypeOptions = damageTypes.hasValue
                            ? damageTypes.value!
                                .where((type) => type.category == category)
                                .map((type) => type.nameJp)
                                .toList()
                            : [_initialDamageType];

                        if (category == 'NON') {
                          _selectedDamageType = _damageTypeOptions.first;
                          _damageTypeController.text = _damageTypeOptions.first;
                          _selectedHealthLevel = 'a';
                        } else {
                          _selectedDamageType = null;
                        }
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
                    initialSelection: _initialDamageType,
                    label: Text(AppLocalizations.of(context)!.damageDetails),
                    enabled: _selectedCategory != null,
                    expandedInsets: const EdgeInsets.all(0),
                    onSelected: (value) {
                      setState(() {
                        _selectedDamageType = value;
                      });
                    },
                    dropdownMenuEntries: _damageTypeOptions.map((type) {
                      return DropdownMenuEntry(
                        value: type,
                        label: type,
                      );
                    }).toList(),
                  )),
                  const SizedBox(width: 8),
                  DropdownMenu<String>(
                    width: 80,
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
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                    minLines: 7,
                    maxLines: null,
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.remark,
                      border: const OutlineInputBorder(),
                      constraints: const BoxConstraints(
                          minHeight: double.infinity,
                          minWidth: double.infinity),
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (orientation == Orientation.landscape)
              buildGoToPhotoSelectionButton(context),
            const Spacer(),
            Row(
              children: [
                if (!result.isSkipped) ...[
                  FilledButton.icon(
                    icon: const Icon(Icons.timer),
                    label: Text(AppLocalizations.of(context)!.holdButton),
                    onPressed: () {
                      submitInspection(InspectionPointReportStatus.pending);
                    },
                    style:
                        FilledButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 16),
                ],
                FilledButton.icon(
                    onPressed: () {
                      submitInspection(result.isSkipped
                          ? InspectionPointReportStatus.skipped
                          : InspectionPointReportStatus.finished);
                    },
                    icon: result.isSkipped
                        ? const Icon(Icons.do_not_disturb)
                        : const Icon(Icons.check),
                    label: result.isSkipped
                        ? Text(AppLocalizations.of(context)!.skipEvaluation)
                        : Text(AppLocalizations.of(context)!.finishEvaluation))
              ],
            )
          ],
        )
      ],
    );
  }

  buildPhotosCarousel(BuildContext context, Orientation orientation) {
    return Column(children: [
      if (MediaQuery.of(context).orientation == Orientation.landscape)
        AppBar(title: Text(widget.point.spanName ?? '')),
      Expanded(
          child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 0.8,
            initialPage: 0,
            enableInfiniteScroll: false,
            reverse: false,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
          items: result.photos.mapIndexed((index, photo) {
            return Builder(
              builder: (BuildContext context) {
                return Stack(
                  children: [
                    photo.url != null
                        ? CachedNetworkImage(
                            imageUrl: photo.url!, fit: BoxFit.fill)
                        : Image.file(
                            File(photo.localPath!),
                            fit: BoxFit.fill,
                          ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child:
                          PhotoSequenceNumberMark(number: photo.sequenceNumber),
                    )
                  ],
                );
              },
            );
          }).toList(),
        ),
      )),
    ]);
  }
}
