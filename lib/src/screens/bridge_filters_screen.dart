import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/contractor.dart';
import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/providers/current_contractor.provider.dart';
import 'package:kyoryo/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo/src/providers/misc.provider.dart';

class BridgeFiltersScreen extends ConsumerWidget {
  const BridgeFiltersScreen({super.key});

  static const routeName = '/filters';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final municipalities = ref.watch(municipalitiesProvider);
    final municipality = ref.watch(currentMunicipalityProvider);
    final municipalityNotifier = ref.read(currentMunicipalityProvider.notifier);
    final contractors = ref.watch(contractorsProvider);
    final contractor = ref.watch(currentContractorProvider);
    final contractorNotifier = ref.read(currentContractorProvider.notifier);

    Autocomplete<Municipality> municipalityAutocomplete() {
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
                border: const OutlineInputBorder(),
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
            if (textEditingValue.text == '' || !municipalities.hasValue) {
              return const Iterable<Municipality>.empty();
            }

            return municipalities.value!.where((Municipality option) {
              return option.nameKanji
                      .contains(textEditingValue.text.toLowerCase()) ||
                  option.nameRomaji!
                      .contains(textEditingValue.text.toLowerCase());
            });
          });
    }

    Autocomplete<Contractor> contractorAutocomplete() {
      return Autocomplete<Contractor>(
          initialValue: TextEditingValue(text: contractor?.nameJp ?? ''),
          onSelected: (option) => contractorNotifier.set(option),
          displayStringForOption: (option) => option.nameJp,
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onFieldSubmitted(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.contractorName,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    textEditingController.clear();
                    contractorNotifier.set(null);
                  },
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '' || !contractors.hasValue) {
              return const Iterable<Contractor>.empty();
            }

            return contractors.value!.where((Contractor option) {
              return option.nameJp
                      .contains(textEditingValue.text.toLowerCase()) ||
                  option.nameEn.contains(textEditingValue.text.toLowerCase());
            });
          });
    }

    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.pleaseSelectAreaAndContractor),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            municipalityAutocomplete(),
            const SizedBox(height: 24),
            contractorAutocomplete(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(55)),
              child: Text(AppLocalizations.of(context)!.showBridgeList),
            ),
          ])),
    );
  }
}
