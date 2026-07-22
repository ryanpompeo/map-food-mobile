import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:cpf_cnpj_validator/cnpj_validator.dart';

class FormValidator {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName é obrigatório";
    }
    return null;
  }

  static String? minLength(String? value, int min, String fieldName) {
    if (value == null || value.length < min) {
      return "$fieldName deve ter pelo menos $min caracteres";
    }
    return null;
  }

  static String? nome(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Nome é obrigatório";
    }

    final nome = value.trim();

    if (nome.length < 3) {
      return "Nome deve ter pelo menos 3 caracteres";
    }

    if (nome.length > 100) {
      return "Nome muito longo";
    }

    final regex = RegExp(r"^[a-zA-ZÀ-ÿ\s\'\-]+$");

    if (!regex.hasMatch(nome)) {
      return "Nome deve conter apenas letras";
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email é obrigatório";
    }

    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!regex.hasMatch(value)) {
      return "Email inválido";
    }

    return null;
  }

  static String? telefone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Telefone é obrigatório";
    }

    final numbersOnly = value.replaceAll(RegExp(r'\D'), '');

    if (numbersOnly.length < 10 || numbersOnly.length > 11) {
      return "Telefone inválido";
    }

    return null;
  }

  static String? telefoneOpcional(String? value) {
    if (value == null || value.isEmpty) return null;
    return telefone(value);
  }

  static String? cep(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "CEP é obrigatório";
    }

    final numbersOnly = value.replaceAll(RegExp(r'\D'), '');

    if (numbersOnly.length != 8) {
      return "CEP inválido";
    }

    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return "CPF obrigatório";
    }

    if (!CPFValidator.isValid(value)) {
      return "CPF inválido";
    }

    return null;
  }

  static String? cnpj(String? value) {
    if (value == null || value.isEmpty) {
      return "CNPJ obrigatório";
    }

    if (!CNPJValidator.isValid(value)) {
      return "CNPJ inválido";
    }

    return null;
  }

  static String? cnpjOpcional(String? value) {
    if (value == null || value.isEmpty) return null;
    return cnpj(value);
  }

  static String? cpfCnpj(String? value) {
    if (value == null || value.isEmpty) {
      return "Documento obrigatório";
    }

    final numbers = value.replaceAll(RegExp(r'\D'), '');

    if (numbers.length <= 11) {
      return cpf(value);
    } else {
      return cnpj(value);
    }
  }

  static String? senha(String? value) {
    if (value == null || value.isEmpty) {
      return "Senha obrigatória";
    }

    if (value.length < 6) {
      return "Mínimo de 6 caracteres";
    }

    return null;
  }

  static int calcularForcaSenha(String senha) {
    int score = 0;

    if (senha.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) score++;
    if (RegExp(r'[0-9]').hasMatch(senha)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(senha)) score++;

    return score; // 0 até 4
  }

  static String? confirmarSenha(String? value, String senhaOriginal) {
    if (value == null || value.isEmpty) {
      return "Confirme sua senha";
    }

    if (value != senhaOriginal) {
      return "As senhas não coincidem";
    }

    return null;
  }

  static String? termos(bool? value) {
    if (value == null || value == false) {
      return "Você precisa aceitar os termos";
    }
    return null;
  }
}
