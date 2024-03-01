import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/bridge_element.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:photo_view/photo_view.dart';

class BridgeElementListItem extends StatelessWidget {
  final BridgeElement element;
  final bool isInspecting;

  const BridgeElementListItem(
      {super.key, required this.element, this.isInspecting = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: SizedBox(
        height: 150,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _imageGroup(context),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    element.name ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.left,
                  ),
                )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    AppLocalizations.of(context)!
                        .lastInspectionDate('23年02月03日 15:30'),
                    style: Theme.of(context).textTheme.bodySmall),
                IconButton(
                    onPressed: isInspecting
                        ? () {
                            Navigator.pushNamed(
                                context, TakePictureScreen.routeName,
                                arguments: element);
                          }
                        : null,
                    icon: const Icon(Icons.photo_camera))
              ],
            )
          ],
        ),
      ),
    );
  }

  Container _imageGroup(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12.0)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(element.name ?? ''),
                    ),
                    body: Center(
                        child: PhotoView(
                      imageProvider: NetworkImage(element.imageUrl!),
                    )),
                  ),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                constraints:
                    const BoxConstraints.expand(height: 100, width: 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  image: DecorationImage(
                    image: NetworkImage(element.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(element.name ?? ''),
                    ),
                    body: Center(
                        child: PhotoView(
                      imageProvider: NetworkImage(element.blueprintUrl!),
                    )),
                  ),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                constraints:
                    const BoxConstraints.expand(height: 100, width: 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  image: DecorationImage(
                    image: NetworkImage(element.blueprintUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12.0)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
