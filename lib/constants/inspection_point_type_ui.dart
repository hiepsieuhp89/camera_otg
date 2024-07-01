import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/inspection_point.dart';

class InspectionPointTypeUI {
  const InspectionPointTypeUI(this.type,
      {required this.label, required this.icon, required this.selectedIcon});

  final InspectionPointType? type;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const presentConditionPointUI = InspectionPointTypeUI(
    InspectionPointType.presentCondition,
    label: '現況点検',
    icon: Icons.image_search_outlined,
    selectedIcon: Icons.image_search);

const damagePointUI = InspectionPointTypeUI(InspectionPointType.damage,
    label: '損傷点検',
    icon: Icons.broken_image_outlined,
    selectedIcon: Icons.broken_image);

const allInspectionPointUI = InspectionPointTypeUI(null,
    label: '全点検',
    icon: Icons.manage_search_outlined,
    selectedIcon: Icons.manage_search);

const inspectionPointTypeUIs = [
  allInspectionPointUI,
  presentConditionPointUI,
  damagePointUI,
];
