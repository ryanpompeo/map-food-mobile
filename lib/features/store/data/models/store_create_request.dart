import 'package:map_food/features/store/data/models/store_dto.dart';

class StoreCreateRequest {
  final String nome;
  final String? descricao;
  final String statusLoja;
  final List<int> categoriaIds;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;
  final double? latitude;
  final double? longitude;

  const StoreCreateRequest({
    required this.nome,
    this.descricao,
    required this.statusLoja,
    required this.categoriaIds,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
    this.latitude,
    this.longitude,
  });

  factory StoreCreateRequest.fromStore(
    StoreDto loja, {
    String? statusLoja,
    double? latitude,
    double? longitude,
  }) =>
      StoreCreateRequest(
        nome: loja.nome,
        descricao: loja.descricao,
        statusLoja: statusLoja ?? loja.statusLoja,
        categoriaIds: loja.categoriaIds,
        endereco: loja.endereco,
        cidade: loja.cidade,
        estado: loja.estado,
        cep: loja.cep,
        latitude: latitude ?? loja.latitude,
        longitude: longitude ?? loja.longitude,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        if (descricao != null) 'descricao': descricao,
        'statusLoja': statusLoja,
        'categorias': categoriaIds.map((id) => {'id': id}).toList(),
        if (endereco != null) 'endereco': endereco,
        if (cidade != null) 'cidade': cidade,
        if (estado != null) 'estado': estado,
        if (cep != null) 'cep': cep,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}
