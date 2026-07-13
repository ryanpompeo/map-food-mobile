import 'package:dio/dio.dart';

/// Endereço resolvido a partir de um CEP.
class CepResult {
  final String? logradouro;
  final String? cidade;
  final String? uf;

  const CepResult({this.logradouro, this.cidade, this.uf});
}

/// Busca endereço por CEP na API pública do ViaCEP — grátis, sem chave e
/// com CORS liberado (funciona também no web). Usa um Dio avulso porque a
/// URL é externa (não passa pelo ApiClient da API interna do MapFood).
class CepService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  /// Devolve o endereço do [cep] (8 dígitos, com ou sem hífen), ou null se
  /// o CEP não existir ou a busca falhar — quem chama segue sem autofill.
  Future<CepResult?> buscar(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://viacep.com.br/ws/$digits/json/',
      );
      final data = response.data;
      if (data == null || data['erro'] == true) return null;

      return CepResult(
        logradouro: data['logradouro'] as String?,
        cidade: data['localidade'] as String?,
        uf: data['uf'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
