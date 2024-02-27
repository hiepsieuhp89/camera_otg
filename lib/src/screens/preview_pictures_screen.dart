import 'dart:io'; // Import dart:io for using File class

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PreviewPicturesScreen extends StatefulWidget {
  final List<String> imagePaths;

  static const routeName = '/preview-pictures';

  const PreviewPicturesScreen({super.key, required this.imagePaths});

  @override
  _PreviewPicturesScreenState createState() => _PreviewPicturesScreenState();
}

class _PreviewPicturesScreenState extends State<PreviewPicturesScreen> {
  late List<String> imagePaths;

  @override
  void initState() {
    super.initState();
    imagePaths = widget.imagePaths;
  }

  void removeImage(String path) {
    setState(() {
      imagePaths.remove(path);
    });
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context, imagePaths);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.previewPicturesTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, imagePaths),
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(imagePaths[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: FloatingActionButton.small(
                        onPressed: () => removeImage(imagePaths[index]),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
