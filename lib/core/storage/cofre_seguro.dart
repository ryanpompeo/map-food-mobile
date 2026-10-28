import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CofreSeguro {
  Future<String?> ler(String chave);

  Future<void> gravar(String chave, String valor);

  Future<void> apagar(String chave);
}

class CofreDoAparelho implements CofreSeguro {
  static const FlutterSecureStorage _cofre = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  const CofreDoAparelho();

  @override
  Future<String?> ler(String chave) async {
    try {
      return await _cofre.read(key: chave);
    } catch (erro) {
      debugPrint('Cofre do aparelho não respondeu na leitura: $erro');
      return null;
    }
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    try {
      await _cofre.write(key: chave, value: valor);
    } catch (erro) {
      debugPrint('Cofre do aparelho não respondeu na gravação: $erro');
    }
  }

  @override
  Future<void> apagar(String chave) async {
    try {
      await _cofre.delete(key: chave);
    } catch (erro) {
      debugPrint('Cofre do aparelho não respondeu ao apagar: $erro');
    }
  }
}

class CofreEmMemoria implements CofreSeguro {
  final Map<String, String> valores = {};
  bool quebrado = false;

  @override
  Future<String?> ler(String chave) async {
    if (quebrado) return null;
    return valores[chave];
  }

  @override
  Future<void> gravar(String chave, String valor) async {
    if (quebrado) return;
    valores[chave] = valor;
  }

  @override
  Future<void> apagar(String chave) async {
    valores.remove(chave);
  }
}

CofreSeguro cofreDoApp = const CofreDoAparelho();

@visibleForTesting
void substituirCofre(CofreSeguro cofre) => cofreDoApp = cofre;

@visibleForTesting
void restaurarCofre() => cofreDoApp = const CofreDoAparelho();
