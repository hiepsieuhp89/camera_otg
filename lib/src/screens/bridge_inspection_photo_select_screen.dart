import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/bridge_element.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';

class BridgeInspectionPhotoSelectScreenArguments {
  final BridgeElement element;
  final List<String> capturedImages;

  BridgeInspectionPhotoSelectScreenArguments({
    required this.element,
    required this.capturedImages,
  });
}

class BridgeInspectionPhotoSelectScreen extends StatefulWidget {
  static const routeName = '/bridge-inspection-photo-select';
  final BridgeInspectionPhotoSelectScreenArguments arguments;

  const BridgeInspectionPhotoSelectScreen({super.key, required this.arguments});

  @override
  State<BridgeInspectionPhotoSelectScreen> createState() =>
      _BridgeInspectionPhotoSelectScreenState();
}

class _BridgeInspectionPhotoSelectScreenState
    extends State<BridgeInspectionPhotoSelectScreen> {
  String? selectedImage;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedImage = null;
    });
  }

  void _moveToEvaluationScreen() {
    if (selectedImage != null) {
      Navigator.pushNamed(context, BridgeInspectionEvaluationScreen.routeName,
          arguments: BridgeInspectionEvaluationScreenArguments(
              element: widget.arguments.element,
              selectedImage: selectedImage!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.pleaseSelectAPhoto),
        ),
        floatingActionButton: selectedImage != null
            ? FloatingActionButton(
                onPressed: _moveToEvaluationScreen,
                child: const Icon(Icons.arrow_forward),
              )
            : null,
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lastInspectionPhoto,
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Image.network(widget.arguments.element.imageUrl!),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.currentInspectionPhoto,
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                          child: GridView.builder(
                              itemCount: widget.arguments.capturedImages.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedImage = widget
                                          .arguments.capturedImages[index];
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade500),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          image: DecorationImage(
                                            image: FileImage(File(widget
                                                .arguments
                                                .capturedImages[index])),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (selectedImage ==
                                          widget
                                              .arguments.capturedImages[index])
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Icon(
                                            Icons.check_circle,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }))
                    ],
                  ))
            ],
          ),
        ));
  }
}
