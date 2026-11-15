/// Lembrete de coleta seletiva (RF04): horário, título e dias da semana.
///
/// Os dias seguem o padrão do Dart: 1 = segunda ([DateTime.monday]) até
/// 7 = domingo ([DateTime.sunday]).
class Lembrete {
  Lembrete({
    required this.id,
    required this.hora,
    required this.minuto,
    required this.titulo,
    required Set<int> dias,
  }) : dias = Set.unmodifiable(dias);

  final int id;
  final int hora;
  final int minuto;
  final String titulo;
  final Set<int> dias;

  static const nomesDias = {
    DateTime.monday: 'Segunda-feira',
    DateTime.tuesday: 'Terça-feira',
    DateTime.wednesday: 'Quarta-feira',
    DateTime.thursday: 'Quinta-feira',
    DateTime.friday: 'Sexta-feira',
    DateTime.saturday: 'Sábado',
    DateTime.sunday: 'Domingo',
  };

  static const _abreviados = {
    DateTime.monday: 'Seg',
    DateTime.tuesday: 'Ter',
    DateTime.wednesday: 'Qua',
    DateTime.thursday: 'Qui',
    DateTime.friday: 'Sex',
    DateTime.saturday: 'Sáb',
    DateTime.sunday: 'Dom',
  };

  /// "08:00"
  String get horario => '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  /// "Terça-feira", "Seg, Qua e Sex", "Dias úteis" ou "Todos os dias".
  String get descricaoDias {
    final ordenados = dias.toList()..sort();
    if (ordenados.length == 7) return 'Todos os dias';
    if (ordenados.length == 5 && ordenados.every((d) => d <= DateTime.friday)) return 'Dias úteis';
    if (ordenados.length == 1) return nomesDias[ordenados.first]!;
    final nomes = ordenados.map((d) => _abreviados[d]!).toList();
    return '${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
  }

  /// "Terça-feira às 08:00", como no protótipo.
  String get resumo => '$descricaoDias às $horario';

  Lembrete copyWith({int? hora, int? minuto, String? titulo, Set<int>? dias}) {
    return Lembrete(
      id: id,
      hora: hora ?? this.hora,
      minuto: minuto ?? this.minuto,
      titulo: titulo ?? this.titulo,
      dias: dias ?? this.dias,
    );
  }

  factory Lembrete.fromJson(Map<String, dynamic> json) {
    return Lembrete(
      id: json['id'] as int,
      hora: json['hora'] as int,
      minuto: json['minuto'] as int,
      titulo: json['titulo'] as String,
      dias: (json['dias'] as List<dynamic>).cast<int>().toSet(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hora': hora,
      'minuto': minuto,
      'titulo': titulo,
      'dias': (dias.toList()..sort()),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lembrete &&
          id == other.id &&
          hora == other.hora &&
          minuto == other.minuto &&
          titulo == other.titulo &&
          dias.length == other.dias.length &&
          dias.containsAll(other.dias);

  @override
  int get hashCode => Object.hash(id, hora, minuto, titulo, Object.hashAllUnordered(dias));
}
