/// Conteúdo educativo sobre compostagem doméstica (RF06), lido de
/// assets/data/compostagem.json. É editado pela equipe; o usuário só consulta.
class GuiaCompostagem {
  const GuiaCompostagem({
    required this.introducao,
    required this.podeVerdes,
    required this.podeSecos,
    required this.naoPode,
    required this.passos,
    required this.chorume,
    required this.problemas,
    required this.semEspaco,
  });

  final String introducao;
  final List<String> podeVerdes; // restos úmidos, que trazem nitrogênio
  final List<String> podeSecos; // material seco, que cobre e tira o cheiro
  final List<ItemProibido> naoPode;
  final List<String> passos;
  final String chorume;
  final List<ProblemaCompostagem> problemas;
  final String semEspaco;

  factory GuiaCompostagem.fromJson(Map<String, dynamic> json) {
    return GuiaCompostagem(
      introducao: json['introducao'],
      podeVerdes: List<String>.from(json['podeVerdes']),
      podeSecos: List<String>.from(json['podeSecos']),
      naoPode: [for (final i in json['naoPode']) ItemProibido.fromJson(i)],
      passos: List<String>.from(json['passos']),
      chorume: json['chorume'],
      problemas: [for (final p in json['problemas']) ProblemaCompostagem.fromJson(p)],
      semEspaco: json['semEspaco'],
    );
  }
}

class ItemProibido {
  const ItemProibido({required this.item, required this.motivo});

  final String item;
  final String motivo;

  factory ItemProibido.fromJson(Map<String, dynamic> json) =>
      ItemProibido(item: json['item'], motivo: json['motivo']);
}

class ProblemaCompostagem {
  const ProblemaCompostagem({required this.problema, required this.solucao});

  final String problema;
  final String solucao;

  factory ProblemaCompostagem.fromJson(Map<String, dynamic> json) =>
      ProblemaCompostagem(problema: json['problema'], solucao: json['solucao']);
}
