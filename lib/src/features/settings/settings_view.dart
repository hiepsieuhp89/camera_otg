import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'settings_controller.dart';

enum Prefectures {
  aichi('愛知県', 'Aichi'),
  akita('秋田県', 'Akita'),
  aomori('青森県', 'Aomori');

  const Prefectures(this.label, this.value);
  final String label;
  final String value;
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

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
    return DropdownMenu(
        expandedInsets: const EdgeInsets.all(0),
        enableFilter: true,
        menuStyle:
            MenuStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
        dropdownMenuEntries:
            Prefectures.values.map<DropdownMenuEntry<Prefectures>>(
          (Prefectures prefecture) {
            return DropdownMenuEntry<Prefectures>(
              value: prefecture,
              label: prefecture.label,
            );
          },
        ).toList());
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
