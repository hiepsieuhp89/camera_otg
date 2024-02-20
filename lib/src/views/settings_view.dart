import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo_flutter/src/models/municipality.dart';
import 'package:kyoryo_flutter/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo_flutter/src/providers/municipalities.provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final municipalities = ref.watch(municipalitiesProvider);
    final municipality = ref.watch(currentMunicipalityProvider);
    final municipalityNotifier = ref.read(currentMunicipalityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.pleaseSelectAreaAndContractor),
      ),
      body: municipalities.maybeWhen(
        orElse: () => _loadingIndicator(),
        data: (data) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _municipalitySelect(municipality, municipalityNotifier, data),
              const SizedBox(height: 24),
              _contractorSelect(),
            ])),
      ),
    );
  }

  DropdownMenu<Municipality> _municipalitySelect(Municipality? municipality,
      CurrentMunicipality municipalityNotifier, List<Municipality> data) {
    return DropdownMenu<Municipality>(
        expandedInsets: const EdgeInsets.all(0),
        menuStyle:
            MenuStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
        enableSearch: true,
        initialSelection: municipality,
        onSelected: (value) {
          municipalityNotifier.set(value);
        },
        dropdownMenuEntries: data
            .map((municipality) => DropdownMenuEntry<Municipality>(
                value: municipality, label: municipality.nameKanji))
            .toList());
  }

  DropdownMenu<String> _contractorSelect() {
    return const DropdownMenu(
        expandedInsets: EdgeInsets.all(0),
        initialSelection: 'A',
        dropdownMenuEntries: [
          DropdownMenuEntry<String>(value: 'A', label: 'A'),
          DropdownMenuEntry<String>(value: 'B', label: 'B'),
          DropdownMenuEntry<String>(value: 'C', label: 'C'),
        ]);
  }

  Widget _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
