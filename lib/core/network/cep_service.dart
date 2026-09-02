import 'package:dio/dio.dart';

class CepResult {
  final String? logradouro;
  final String? cidade;
  final String? uf;

  const CepResult({this.logradouro, this.cidade, this.uf});
}

class CepService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  Future<CepResult?> buscarEnderecoPorCep(String cep) async {
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
