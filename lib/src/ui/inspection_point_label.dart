import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';

class InspectionPointLabel extends StatelessWidget {
  final InspectionPoint point;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final TextStyle? style;

  const InspectionPointLabel(
      {super.key,
      required this.point,
      this.textAlign,
      this.overflow,
      this.style});

  @override
  Widget build(BuildContext context) {
    String labelText;

    if (point.type == InspectionPointType.damage) {
      labelText =
          '${point.spanNumber ?? ''} - ${point.photoRefNumber ?? ''} : ${point.spanName ?? ''} / ${point.elementNumber ?? ''}';
    } else {
      String photoRefNumberWithLabel = point.photoRefNumber != null
          ? '${AppLocalizations.of(context)!.photoRefNumber(point.photoRefNumber.toString())}：'
          : '';
      labelText = '$photoRefNumberWithLabel${point.spanName ?? ''}';
    }

    return Text(
      labelText,
      style: style,
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
