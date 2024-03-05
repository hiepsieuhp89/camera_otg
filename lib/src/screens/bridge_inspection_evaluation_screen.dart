import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/screens/bridge_inspection_screen.dart';

class BridgeInspectionEvaluationScreenArguments {
  final InspectionPoint point;
  final String selectedImage;

  BridgeInspectionEvaluationScreenArguments({
    required this.point,
    required this.selectedImage,
  });
}

class BridgeInspectionEvaluationScreen extends StatefulWidget {
  static const routeName = '/bridge-inspection-evaluation';
  final BridgeInspectionEvaluationScreenArguments arguments;

  const BridgeInspectionEvaluationScreen({super.key, required this.arguments});

  @override
  State<BridgeInspectionEvaluationScreen> createState() =>
      _BridgeInspectionEvaluationScreenState();
}

class _BridgeInspectionEvaluationScreenState
    extends State<BridgeInspectionEvaluationScreen> {
  void _submitInspection() {
    Navigator.popUntil(
        context, ModalRoute.withName(BridgeInspectionScreen.routeName));
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
                      child: Image(
                          image:
                              FileImage(File(widget.arguments.selectedImage)),
                          fit: BoxFit.cover))
                ]),
              ),
              const SizedBox(height: 16),
              Expanded(
                  flex: 2,
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
              FilledButton(
                onPressed: _submitInspection,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(55)),
                child: Text(AppLocalizations.of(context)!.finishInspection),
              )
            ],
          ),
        ));
  }
}
