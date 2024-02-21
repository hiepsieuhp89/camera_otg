class Bridge {
  final String nameKanji;
  final String nameKana;
  final Uri? imageUrl;
  final DateTime? lastInspectionDate;
  final String managementNo;
  final String bridgeNo;
  final String condition;

  const Bridge(
      {required this.nameKanji,
      required this.nameKana,
      required this.managementNo,
      required this.bridgeNo,
      required this.condition,
      this.imageUrl,
      this.lastInspectionDate});
}
