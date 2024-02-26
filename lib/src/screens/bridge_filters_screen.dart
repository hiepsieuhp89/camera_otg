import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo/src/providers/municipalities.provider.dart';

class BridgeFiltersScreen extends ConsumerWidget {
  const BridgeFiltersScreen({super.key});

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
              _contractorSelect(context),
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
        initialValue: TextEditingValue(text: municipality?.nameKanji ?? ''),
        onSelected: (option) => municipalityNotifier.set(option),
        displayStringForOption: (option) => option.nameKanji,
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            onFieldSubmitted: (_) => onFieldSubmitted(),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.municipalityName,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textEditingController.clear();
                  municipalityNotifier.set(null);
                },
              ),
            ),
          );
        },
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

  DropdownMenu<String> _contractorSelect(BuildContext context) {
    return DropdownMenu(
      label: Text(AppLocalizations.of(context)!.contractorName),
      enabled: false,
      expandedInsets: const EdgeInsets.all(0),
      dropdownMenuEntries: const [],
    );
  }

  Widget _confirmButton(BuildContext context) {
    return FilledButton(
      onPressed: () => Navigator.pop(context),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(55)),
      child: Text(AppLocalizations.of(context)!.showBridgeList),
    );
  }

  Widget _loadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
