import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/diagrams.provider.dart';
import 'package:kyoryo/src/screens/inspection_point_damage_mark_screen.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

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
  Diagram? _selectedDiagram;
  Future<void>? _diagramFuture;
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

  void _goToDamageMarkScreen(Diagram selected) {
    Navigator.of(context).pushNamed(InspectionPointDamageMarkScreen.routeName,
        arguments: InspectionPointDamageMarkScreenArguments(diagram: selected));
  }

  void _proceedWithSelectedDiagram() {
    final bridgeId = ref.watch(currentBridgeProvider)!.id;

    if (_selectedDiagramPath != null) {
      _diagramFuture = ref
          .watch(diagramsProvider(bridgeId).notifier)
          .createDiagram(bridgeId, _selectedDiagramPath!,
              MediaQuery.of(context).orientation)
          .then((value) {
        _goToDamageMarkScreen(value);
      });
      setState(() {});
      return;
    }

    if (_selectedDiagram != null) {
      _goToDamageMarkScreen(_selectedDiagram!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (_selectedDiagramPath == null &&
              _selectedDiagram == null)
          ? null
          : FutureBuilder(
              future: _diagramFuture,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return FloatingActionButton(
                    onPressed: isLoading ? null : _proceedWithSelectedDiagram,
                    child: isLoading
                        ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                            ))
                        : const Icon(Icons.arrow_forward));
              }),
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.diagramSelection),
          actions: MediaQuery.of(context).orientation == Orientation.landscape
              ? [
                  ActionChip(
                      avatar: const Icon(Icons.add_a_photo_outlined),
                      label: Text(AppLocalizations.of(context)!.takePhoto),
                      onPressed: _takePhoto),
                  const SizedBox(width: 16),
                  ActionChip(
                    avatar: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(AppLocalizations.of(context)!.selectPhoto),
                    onPressed: _selectPhotoFromGallery,
                  ),
                  const SizedBox(width: 16),
                ]
              : []),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OrientationBuilder(
            builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? Column(children: [
                      Expanded(
                          child: buildNewDiagramPhotoSelection(
                              context, orientation)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: buildCurrentDiagramPhotoSelection(context),
                      )
                    ])
                  : Row(
                      children: [
                        Expanded(
                            child: buildNewDiagramPhotoSelection(
                                context, orientation)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: buildCurrentDiagramPhotoSelection(context),
                        ),
                      ],
                    );
            },
          )),
    );
  }

  Stack buildImage(
      {required bool isSelected, File? imageFile, Diagram? diagram}) {
    Widget image;

    if (diagram != null) {
      image = CachedNetworkImage(
          imageUrl: diagram.photo!.photoLink, fit: BoxFit.cover);
    } else if (imageFile != null) {
      image = Image.file(imageFile);
    } else {
      throw ArgumentError('Either imageFile or diagram must be provided');
    }

    return Stack(
      children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.decelerate,
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(
                      color: Colors.grey[200]!,
                      width: 12,
                    )
                  : const Border(),
            ),
            child: !isSelected
                ? SizedBox(width: 300, height: 300, child: image)
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0,
                        color: Colors.grey[200]!,
                      ),
                      color: Colors.grey[200]!,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: SizedBox(width: 300, height: 300, child: image),
                    ),
                  )),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200]!,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        if (diagram != null)
          Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.black26),
                child: IconButton(
                    icon: const Icon(
                      Icons.open_in_full,
                      color: Colors.white,
                      size: 14,
                    ),
                    onPressed: () {
                      viewImage(context, imageUrl: diagram.photo!.photoLink);
                    }),
              ))
      ],
    );
  }

  Column buildCurrentDiagramPhotoSelection(BuildContext context) {
    final diagrams =
        ref.watch(diagramsProvider(ref.watch(currentBridgeProvider)!.id));

    return Column(
      children: [
        Row(children: [
          Text(
            AppLocalizations.of(context)!.currentDiagramPhotos,
            style: Theme.of(context).textTheme.labelLarge,
          )
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: diagrams.when(
              data: (data) => data.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)!.noPhotosYet,
                          style: Theme.of(context).textTheme.titleSmall),
                    )
                  : GridView.builder(
                      itemCount: data.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 150,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedDiagramPath != null) {
                                _selectedDiagramPath = null;
                              }

                              if (_selectedDiagram?.id == data[index].id) {
                                _selectedDiagram = null;
                              } else {
                                _selectedDiagram = data[index];
                              }
                            });
                          },
                          child: buildImage(
                              isSelected:
                                  data[index].id == _selectedDiagram?.id,
                              diagram: data[index]),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(error.toString())),
        )
      ],
    );
  }

  Column buildNewDiagramPhotoSelection(
      BuildContext context, Orientation orientation) {
    return Column(
      children: [
        Row(children: [
          Text(
            AppLocalizations.of(context)!.newDiagramPhotos,
            style: Theme.of(context).textTheme.labelLarge,
          )
        ]),
        const SizedBox(height: 8),
        Visibility(
          visible: orientation == Orientation.portrait,
          child: Row(
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
        ),
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
                        mainAxisExtent: 150,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        String photoPath = _newPhotoPaths[index];

                        return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedDiagram != null) {
                                  _selectedDiagram = null;
                                }

                                if (_selectedDiagramPath == photoPath) {
                                  _selectedDiagramPath = null;
                                } else {
                                  _selectedDiagramPath = photoPath;
                                }
                              });
                            },
                            child: buildImage(
                              isSelected: _selectedDiagramPath == photoPath,
                              imageFile: File(photoPath),
                            ));
                      },
                    ),
                  ))
      ],
    );
  }
}
