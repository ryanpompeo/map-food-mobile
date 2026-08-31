import 'package:map_food/core/network/api_client.dart';

/// Envio de mensagem para os administradores da plataforma.
///
/// `POST /contato` é público (não exige token) e o servidor encaminha a
/// mensagem por e-mail — não há listagem, edição nem histórico: é um envio e
/// pronto, do mesmo jeito que no site.
///
/// **Tem limite de taxa: 3 envios por minuto, por IP.** Estourar devolve 429,
/// e o [ErrorInterceptor] traduz isso em `AppException`. Vale o texto do
/// backend, não uma mensagem inventada aqui.
class ContatoService {
  ContatoService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  static const String _path = '/contato';

  /// [telefone] é o único campo opcional — o backend valida os demais como
  /// obrigatórios. Vazio é omitido do corpo em vez de ir como string vazia:
  /// o campo tem `@Size(max = 30)` e aceita nulo, mas mandar `""` deixa o
  /// e-mail que o administrador recebe com um rótulo de telefone em branco.
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
