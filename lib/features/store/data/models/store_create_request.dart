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

  /// Payload completo de uma loja existente, com os campos indicados
  /// sobrescritos.
  ///
  /// Ponto único que define "o que é o corpo de um PUT de loja". Antes, cada
  /// tela montava o seu: a ronda de GPS em `MerchantWorkingPage` omitia
  /// `endereco`, `cidade`, `estado` e `cep` a cada envio de posição — se o
  /// backend fizer replace (e não merge) nesses campos, cada deslocamento do
  /// comerciante apagava o endereço cadastrado da loja.
  ///
  /// Regra de negócio preservada: `statusLoja` só muda quando explicitamente
  /// informado. `SUSPENSA` é decisão exclusiva de administrador e nunca deve
  /// partir do app do comerciante.
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
