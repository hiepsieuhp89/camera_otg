import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo_flutter/src/models/municipality.dart';
import 'package:kyoryo_flutter/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo_flutter/src/providers/municipalities.provider.dart';

class BridgeFiltersView extends ConsumerWidget {
  const BridgeFiltersView({super.key});

  static const routeName = '/filters';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final municipalities = ref.watch(municipalitiesProvider);
    final municipality = ref.watch(currentMunicipalityProvider);
    final municipalityNotifier = ref.read(currentMunicipalityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.pleaseSelectAreaAndContractor),
        automaticallyImplyLeading: false,
      ),
      body: municipalities.maybeWhen(
        orElse: () => _loadingIndicator(),
        data: (data) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _municipalityAutocomplete(
                  municipality, municipalityNotifier, data),
              const SizedBox(height: 24),
              _contractorSelect(),
              const SizedBox(height: 24),
              _confirmButton(context),
            ])),
      ),
    );
  }

  Autocomplete<Municipality> _municipalityAutocomplete(
      Municipality? municipality,
      CurrentMunicipality municipalityNotifier,
      List<Municipality> data) {
    return Autocomplete<Municipality>(
        initialValue: TextEditingValue(text: municipality!.nameKanji),
        onSelected: (option) => municipalityNotifier.set(option),
        displayStringForOption: (option) => option.nameKanji,
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text == '') {
            return const Iterable<Municipality>.empty();
          }
          return data.where((Municipality option) {
            return option.nameKanji
                    .contains(textEditingValue.text.toLowerCase()) ||
                option.nameRomaji!
                    .contains(textEditingValue.text.toLowerCase());
          });
        });
  }

  Widget _confirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.showBridgeList)),
    );
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
