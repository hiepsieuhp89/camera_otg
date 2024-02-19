import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo_flutter/src/models/municipality.dart';
import 'package:kyoryo_flutter/src/providers/municipalitiy.provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.pleaseSelectAreaAndContractor),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _areaSelect(),
            const SizedBox(height: 24),
            _contractorSelect(),
          ])),
    );
  }

  Widget _areaSelect() {
    return Consumer(
      builder: (context, ref, child) {
        final AsyncValue<List<Municipality>> municipalities =
            ref.watch(municipalitiesProvider);

        return DropdownMenu(
            expandedInsets: const EdgeInsets.all(0),
            menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white)),
            enableSearch: true,
            dropdownMenuEntries: switch (municipalities) {
              AsyncData(:final value) => value
                  .map((municipality) => DropdownMenuEntry<String>(
                      value: municipality.code, label: municipality.nameKanji))
                  .toList(),
              AsyncError() => [],
              _ => [],
            });
      },
    );
  }

  Widget _contractorSelect() {
    return const DropdownMenu(
        expandedInsets: EdgeInsets.all(0),
        initialSelection: 'A',
        dropdownMenuEntries: [
          DropdownMenuEntry<String>(value: 'A', label: 'A'),
          DropdownMenuEntry<String>(value: 'B', label: 'B'),
          DropdownMenuEntry<String>(value: 'C', label: 'C'),
        ]);
  }
}
