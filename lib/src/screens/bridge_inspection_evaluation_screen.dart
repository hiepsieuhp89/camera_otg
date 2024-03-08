import 'dart:io';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
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

  Future<void> submitInspection() async {
    final reportSubmission = ref
        .read(
            bridgeInspectionProvider(widget.arguments.point.bridgeId!).notifier)
        .createReport(
            widget.arguments.point.id!, widget.arguments.capturedPhotos)
        .then((_) {
      Navigator.popUntil(
          context, ModalRoute.withName(BridgeInspectionScreen.routeName));
    });

    setState(() {
      _pendingSubmssion = reportSubmission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(widget.arguments.point.name!)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Column(children: [
                  Row(children: [
                    Text(
                      AppLocalizations.of(context)!.currentInspectionPhoto,
                      style: Theme.of(context).textTheme.labelLarge,
                    )
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                      child: CarouselSlider(
                    options: CarouselOptions(
                      viewportFraction: 0.6,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {},
                      scrollDirection: Axis.horizontal,
                    ),
                    items: widget.arguments.capturedPhotos.map((photo) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Image(
                            image: FileImage(File(photo)),
                            fit: BoxFit.cover,
                          );
                        },
                      );
                    }).toList(),
                  ))
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
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: DropdownMenu(
                            label:
                                Text(AppLocalizations.of(context)!.damageType),
                            enabled: false,
                            expandedInsets: const EdgeInsets.all(0),
                            dropdownMenuEntries: const [],
                          )),
                          const SizedBox(width: 8),
                          Expanded(
                              child: DropdownMenu(
                            label: Text(
                                AppLocalizations.of(context)!.damageDetails),
                            enabled: false,
                            expandedInsets: const EdgeInsets.all(0),
                            dropdownMenuEntries: const [],
                          ))
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownMenu(
                        label: Text(AppLocalizations.of(context)!.damage),
                        enabled: false,
                        expandedInsets: const EdgeInsets.all(0),
                        dropdownMenuEntries: const [],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                          decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.freeComment),
                        border: const OutlineInputBorder(),
                      ))
                    ],
                  )),
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
                          Text(AppLocalizations.of(context)!.finishInspection),
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
}
