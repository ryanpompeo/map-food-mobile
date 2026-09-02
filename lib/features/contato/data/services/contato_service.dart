import 'package:map_food/core/network/api_client.dart';

class ContatoService {
  ContatoService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static const String _path = '/contato';

  Future<void> enviar({
    required String nome,
    required String email,
    String? telefone,
    required String assunto,
    required String mensagem,
  }) async {
    final tel = telefone?.trim();
    await _client.post<dynamic>(
      _path,
      data: {
        'nome': nome.trim(),
        'email': email.trim(),
        if (tel != null && tel.isNotEmpty) 'telefone': tel,
        'assunto': assunto.trim(),
        'mensagem': mensagem.trim(),
      },
    );
  }
}
