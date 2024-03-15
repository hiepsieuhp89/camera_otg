import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/screens/inspection_point_damage_mark_screen.dart';

class InpsectionPointDiagramSelectScreen extends ConsumerStatefulWidget {
  const InpsectionPointDiagramSelectScreen({super.key});

  static const routeName = '/new-inspection-point-diagram-selection';

  @override
  ConsumerState<InpsectionPointDiagramSelectScreen> createState() =>
      InpsectionPointDiagramSelectScreenState();
}

class InpsectionPointDiagramSelectScreenState
    extends ConsumerState<InpsectionPointDiagramSelectScreen> {
  String? _selectedDiagramPath;
  final List<String> _newPhotoPaths = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectPhotoFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _newPhotoPaths.add(pickedImage.path);
        _selectedDiagramPath ??= pickedImage.path;
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _newPhotoPaths.add(pickedImage.path);

        _selectedDiagramPath ??= pickedImage.path;
      });
    }
  }

  void _goToDamageMarkScreen() {
    Navigator.of(context).pushNamed(InspectionPointDamageMarkScreen.routeName,
        arguments: InspectionPointDamageMarkScreenArguments(
            diagramPath: _selectedDiagramPath!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedDiagramPath == null
          ? null
          : FloatingActionButton(
              onPressed: _goToDamageMarkScreen,
              child: const Icon(Icons.check),
            ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.diagramSelection),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(
            children: [
              ActionChip(
                  avatar: const Icon(Icons.add_a_photo_outlined),
                  label: Text(AppLocalizations.of(context)!.takePhoto),
                  onPressed: _takePhoto),
              const SizedBox(width: 16),
              ActionChip(
                avatar: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(AppLocalizations.of(context)!.selectPhoto),
                onPressed: _selectPhotoFromGallery,
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Text(
              AppLocalizations.of(context)!.newDiagramPhotos,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ]),
          const SizedBox(height: 8),
          Expanded(
              child: _newPhotoPaths.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)!.noPhotosYet,
                          style: Theme.of(context).textTheme.titleSmall),
                    )
                  : Flexible(
                      child: GridView.builder(
                        itemCount: _newPhotoPaths.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          String photoPath = _newPhotoPaths[index];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedDiagramPath == photoPath) {
                                  _selectedDiagramPath = null;
                                } else {
                                  _selectedDiagramPath = photoPath;
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                Container(
                                    height: 150,
                                    color: Colors.grey[200],
                                    padding: _selectedDiagramPath == photoPath
                                        ? const EdgeInsets.all(24)
                                        : null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            _selectedDiagramPath == photoPath
                                                ? BorderRadius.circular(8)
                                                : null,
                                        image: DecorationImage(
                                          image: FileImage(File(photoPath)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                                _selectedDiagramPath == photoPath
                                    ? Positioned(
                                        top: 4,
                                        right: 4,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          );
                        },
                      ),
                    )),
          const SizedBox(height: 16),
          Row(children: [
            Text(
              AppLocalizations.of(context)!.currentDiagramPhotos,
              style: Theme.of(context).textTheme.labelLarge,
            )
          ]),
          Expanded(
            child: Center(
              child: Text(AppLocalizations.of(context)!.noPhotosYet,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
          )
        ]),
      ),
    );
  }
}
