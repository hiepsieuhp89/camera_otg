import 'package:flutter/material.dart';

class SelectedPhotoCheckMark extends StatelessWidget {
  final bool isSelected;

  const SelectedPhotoCheckMark({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration:
          const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
      child: Icon(Icons.check_circle,
          color: isSelected ? Colors.green[400] : Colors.grey),
    );
  }
}
