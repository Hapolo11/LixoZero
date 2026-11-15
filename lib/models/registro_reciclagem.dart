class RegistroReciclagem {
  const RegistroReciclagem({
    required this.id,
    required this.item,
    required this.pesoKg,
    required this.data,
  });

  final String id;
  final String item;
  final double pesoKg;
  final DateTime data;

  RegistroReciclagem copyWith({
    String? id,
    String? item,
    double? pesoKg,
    DateTime? data,
  }) {
    return RegistroReciclagem(
      id: id ?? this.id,
      item: item ?? this.item,
      pesoKg: pesoKg ?? this.pesoKg,
      data: data ?? this.data,
    );
  }

  factory RegistroReciclagem.fromJson(Map<String, dynamic> json) {
    return RegistroReciclagem(
      id: json['id'] as String,
      item: json['item'] as String,
      pesoKg: (json['pesoKg'] as num).toDouble(),
      data: DateTime.parse(json['data'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item,
      'pesoKg': pesoKg,
      'data': data.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistroReciclagem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          item == other.item &&
          pesoKg == other.pesoKg &&
          data == other.data;

  @override
  int get hashCode => Object.hash(id, item, pesoKg, data);
}

