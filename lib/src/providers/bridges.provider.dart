import 'package:kyoryo_flutter/src/models/bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridges.provider.g.dart';

@riverpod
class Bridges extends _$Bridges {
  @override
  Future<List<Bridge>> build() async {
    return [
      Bridge(
          nameKanji: '八ヶ山1号橋',
          bridgeNo: '2925',
          managementNo: '1050150511',
          nameKana: 'ｶﾐﾑﾗ9ｺﾞｳｷｮｳ',
          condition: '開水路:排水路',
          lastInspectionDate: DateTime(2024, 1, 1, 4, 1, 44)),
      Bridge(
          nameKanji: '八ヶ山1号橋',
          bridgeNo: '2925',
          managementNo: '1050150511',
          nameKana: 'ｶﾐﾑﾗ9ｺﾞｳｷｮｳ',
          condition: '開水路:排水路',
          lastInspectionDate: DateTime.now()),
    ];
  }
}
