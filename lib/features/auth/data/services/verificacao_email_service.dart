import 'package:map_food/core/network/api_client.dart';
import 'package:map_food/core/network/api_constants.dart';
import 'package:map_food/core/session/session_store.dart';

class SituacaoVerificacao {
  final bool jaVerificado;
  final String email;
  final bool codigoPendente;
  final int expiraEmSegundos;
  final int aguardeSegundos;
  final bool limiteDiario;

  const SituacaoVerificacao({
    required this.jaVerificado,
    this.email = '',
    this.codigoPendente = false,
    this.expiraEmSegundos = 0,
    this.aguardeSegundos = 0,
    this.limiteDiario = false,
  });

  factory SituacaoVerificacao.fromJson(Map<String, dynamic> json) => SituacaoVerificacao(
        jaVerificado: json['jaVerificado'] == true,
        email: json['email']?.toString() ?? '',
        codigoPendente: json['codigoPendente'] == true,
        expiraEmSegundos: _inteiro(json['expiraEmSegundos']),
        aguardeSegundos: _inteiro(json['aguardeSegundos']),
        limiteDiario: json['limiteDiario'] == true,
      );

  static int _inteiro(Object? valor) => valor is num ? valor.toInt() : 0;
}

class VerificacaoEmailService {
  VerificacaoEmailService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<SituacaoVerificacao?> situacao() async {
    try {
      final json = await _client.get<Map<String, dynamic>>(ApiConstants.situacaoVerificacao);
      return SituacaoVerificacao.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<int?> enviarCodigo() async {
    final json = await _client.post<Map<String, dynamic>>(ApiConstants.enviarCodigoVerificacao);
    if (json['jaVerificado'] == true) {
      await SessionStore.instance.marcarEmailVerificado(true);
      return null;
    }
    final aguarde = json['aguardeSegundos'];
    return aguarde is num ? aguarde.toInt() : null;
  }

  Future<void> confirmar(String codigo) async {
    await _client.post<dynamic>(
      ApiConstants.verificarEmail,
      data: {'codigo': codigo},
    );
    await SessionStore.instance.marcarEmailVerificado(true);
  }
}
