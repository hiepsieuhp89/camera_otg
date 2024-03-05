import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';

class BridgeInspectionScreen extends ConsumerStatefulWidget {
  const BridgeInspectionScreen({
    super.key,
    required this.bridge,
  });

  final Bridge bridge;
  static const routeName = '/bridge-inspection';

  @override
  ConsumerState<BridgeInspectionScreen> createState() =>
      _BridgeInspectionScreenState();
}

class _BridgeInspectionScreenState
    extends ConsumerState<BridgeInspectionScreen> {
  bool _isInspecting = false;
  bool _isLoading = true;
  List<InspectionPoint> _points = [];

  @override
  void initState() {
    super.initState();
    _fetchElements();
  }

  void _setInspecting(bool value) {
    setState(() {
      _isInspecting = value;
    });
  }

  void _fetchElements() async {
    _isLoading = true;
    final elements =
        await ref.read(bridgeServiceProvider).fetchInspectionPoints();

    setState(() {
      _points = elements;
      _isLoading = false;
    });
  }

  Future<void> _confirmCancelDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.cancelInspection),
          content: SingleChildScrollView(
            child: Text(AppLocalizations.of(context)!.cancelInspectionConfirm),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
                _setInspecting(false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              bottom: TabBar(tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.generalInspection,
                  icon: const Icon(Icons.generating_tokens_outlined),
                ),
                Tab(
                  text: AppLocalizations.of(context)!.damangeInspection,
                  icon: const Icon(Icons.broken_image),
                )
              ]),
              title: Row(
                children: <Widget>[
                  Text(widget.bridge.nameKanji),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline_rounded)),
                ],
              )),
          body: TabBarView(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _points.length,
                      itemBuilder: (context, index) {
                        return InpsectionPointListItem(
                            point: _points[index], isInspecting: _isInspecting);
                      }),
              Center(
                child: Text(AppLocalizations.of(context)!.noDamageFound,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
          bottomSheet: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_isInspecting
                    ? AppLocalizations.of(context)!.finishedTasks(0, 10)
                    : ''),
                Row(
                  children: _isInspecting
                      ? [
                          IconButton(
                              onPressed: _confirmCancelDialog,
                              icon: const Icon(Icons.close)),
                          FilledButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check),
                              label: Text(AppLocalizations.of(context)!
                                  .finishInspection))
                        ]
                      : [
                          FilledButton.icon(
                            onPressed: () => _setInspecting(true),
                            icon: const Icon(Icons.add),
                            label: Text(
                                AppLocalizations.of(context)!.startInspection),
                          )
                        ],
                )
              ],
            ),
          )),
    );
  }
}
