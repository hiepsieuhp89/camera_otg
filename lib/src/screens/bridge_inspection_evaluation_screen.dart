import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/bridge_element.dart';

class BridgeInspectionEvaluationScreenArguments {
  final BridgeElement element;
  final List<String> capturedImages;

  BridgeInspectionEvaluationScreenArguments({
    required this.element,
    required this.capturedImages,
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
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('WIP'),
    );
  }
}
