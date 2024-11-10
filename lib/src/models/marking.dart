class Marking {
  final int x;
  final int y;

  const Marking({required this.x, required this.y});

  Marking copyWith({int? x, int? y}) {
    return Marking(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  toString() {
    return 'Marking(x: $x, y: $y)';
  }
}
