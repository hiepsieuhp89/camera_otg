import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';

import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/screens/bridge_inspection_screen.dart';

class BridgeListItem extends ConsumerWidget {
  final Bridge bridge;

  const BridgeListItem({super.key, required this.bridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text(bridge.nameKanji),
                      ),
                      body: Center(
                          child: PhotoView(
                        imageProvider:
                            const AssetImage('assets/images/bridge1.jpg'),
                      )),
                    ),
                  ),
                );
              },
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    image: DecorationImage(
                      image: AssetImage('assets/images/bridge1.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bridge.nameKanji,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                    Expanded(
                      child: Text(
                        '橋梁管理番号:${bridge.managementNo}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    bridge.lastInspectionDate != null
                        ? Text(
                            '最終点検日時：${DateFormat('yy年MM月dd日 HH:mm').format(bridge.lastInspectionDate!)}',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.black54,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.manage_search_rounded),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, BridgeInspectionScreen.routeName,
                            arguments: bridge);
                      })
                ])
          ],
        ),
      ),
    );
  }
}
