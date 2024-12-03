import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';

@RoutePage()
class PointsInspectionScreen extends ConsumerStatefulWidget {
  final List<InspectionPoint> points;

  const PointsInspectionScreen({super.key, required this.points});

  @override
  PointsInspectionScreenState createState() => PointsInspectionScreenState();
}

class PointsInspectionScreenState
    extends ConsumerState<PointsInspectionScreen> {
  @override
  Widget build(BuildContext context) {
    final currentBridge = ref.watch(currentBridgeProvider);

    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: <Widget>[
          Text(currentBridge?.nameKanji ?? ''),
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.info_outline_rounded)),
        ],
      )),
      body: ListView.builder(
        key: const PageStorageKey<String>('inspection-point-list'),
        itemCount: widget.points.length,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        itemBuilder: (BuildContext context, int index) {
          final point = widget.points[index];

          return InpsectionPointListItem(
            point: point,
          );
        },
      ),
    );
  }
}
