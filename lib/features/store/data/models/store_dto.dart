import 'package:map_food/core/network/json_reader.dart';

class StoreDto {
  final int id;
  final String nome;
  final String? descricao;
  final String statusLoja;
  final String? dataCadastro;
  final String categoria;
  final List<int> categoriaIds;
  final List<String> categoriaNomes;
  final String? imagemUrl;
  final List<String> galeria;
  final double? avaliacao;
  final int totalAvaliacoes;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final double? latitude;
  final double? longitude;

  const StoreDto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.statusLoja,
    this.dataCadastro,
    required this.categoria,
    this.categoriaIds = const [],
    this.categoriaNomes = const [],
    this.imagemUrl,
    this.galeria = const [],
    this.avaliacao,
    this.totalAvaliacoes = 0,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.latitude,
    this.longitude,
  });

  bool get temLocalizacao => latitude != null && longitude != null;

  String? get enderecoCompleto {
    final partes = [
      if (endereco != null && endereco!.isNotEmpty) endereco,
      if (cidade != null && cidade!.isNotEmpty)
        estado != null && estado!.isNotEmpty ? '$cidade - $estado' : cidade,
    ];
    return partes.isEmpty ? null : partes.join(', ');
  }

  String? get capaUrl => imagemUrl ?? (galeria.isNotEmpty ? galeria.first : null);

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
        id: json.requireInt('id'),
        nome: json.stringOr('nome', ''),
        descricao: json.optString('descricao'),
        statusLoja: json.stringOr('statusLoja', 'INATIVA'),
        dataCadastro: json.optString('dataCadastro'),
        categoria: _parseCategoriaName(json),
        categoriaIds: _parseCategoriaIds(json),
        categoriaNomes: _parseCategoriaNames(json),
        imagemUrl: json.optString('imagemUrl'),
        galeria: json.optStringList('galeria'),
        avaliacao: json.optDouble('mediaAvaliacao') ?? json.optDouble('avaliacao'),
        totalAvaliacoes: json.optInt('totalAvaliacoes') ?? 0,
        endereco: json.optString('endereco'),
        cidade: json.optString('cidade'),
        estado: json.optString('estado'),
        cep: json.optString('cep'),
        latitude: json.optDouble('latitude'),
        longitude: json.optDouble('longitude'),
      );

  static String _parseCategoriaName(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List && cats.isNotEmpty) {
      final first = cats.first;
      if (first is Map) return first['nome']?.toString() ?? '';
      return first.toString();
    }
    return json['categoria']?.toString() ?? '';
  }

  static List<String> _parseCategoriaNames(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List) {
      return cats
          .map<String>((e) {
            if (e is Map) return e['nome']?.toString() ?? '';
            return e.toString();
          })
          .where((name) => name.isNotEmpty)
          .toList();
    }
    final fallback = json['categoria']?.toString();
    if (fallback != null && fallback.isNotEmpty) return [fallback];
    return [];
  }

  static List<int> _parseCategoriaIds(Map<String, dynamic> json) {
    final cats = json['categorias'];
    if (cats is List) {
      return cats
          .map<int?>((e) {
            if (e is Map) return (e['id'] as num?)?.toInt();
            if (e is num) return e.toInt();
            return null;
          })
          .whereType<int>()
          .toList();
    }
    return [];
  }
}
