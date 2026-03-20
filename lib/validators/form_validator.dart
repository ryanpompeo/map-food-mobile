import 'package:cpf_cnpj_validator/cpf_validator.dart';

class FormValidator {
  // =============================
  // VALIDAÇÃO GENÉRICA
  // =============================

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

  // =============================
  // NOME
  // =============================

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

    final regex = RegExp(r"^[a-zA-ZÀ-ÿ\s]+$");

    if (!regex.hasMatch(nome)) {
      return "Nome deve conter apenas letras";
    }

    return null;
  }

  // =============================
  // EMAIL
  // =============================

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email é obrigatório";
    }

    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!regex.hasMatch(value)) {
      return "Email inválido";
    }

    return null;
  }

  // =============================
  // TELEFONE
  // =============================

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

  // =============================
  // CPF
  // =============================

  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return "CPF obrigatório";
    }

    final cpf = CPFValidator.isValid(value);

    if (!cpf) {
      return "CPF inválido";
    }

    return null;
  }

  // =============================
  // CNPJ
  // =============================

  static String? cnpj(String? value) {
    if (value == null || value.isEmpty) {
      return "CNPJ obrigatório";
    }

    final cnpj = value.replaceAll(RegExp(r'\D'), '');

    if (cnpj.length != 14) {
      return "CNPJ inválido";
    }

    return null;
  }

  // =============================
  // CPF OU CNPJ
  // =============================

  static String? cpfCnpj(String? value) {
    if (value == null || value.isEmpty) {
      return "Documento obrigatório";
    }

    final numbers = value.replaceAll(RegExp(r'\D'), '');

    if (numbers.length == 11) {
      return cpf(value);
    }

    if (numbers.length == 14) {
      return cnpj(value);
    }

    return "CPF ou CNPJ inválido";
  }

  // =============================
  // SENHA
  // =============================

  static String? senha(String? value) {
    if (value == null || value.isEmpty) {
      return "Senha obrigatória";
    }

    if (value.length < 8) {
      return "Senha deve ter no mínimo 8 caracteres";
    }

    final hasNumber = RegExp(r'[0-9]');
    final hasLetter = RegExp(r'[A-Za-z]');

    if (!hasNumber.hasMatch(value) || !hasLetter.hasMatch(value)) {
      return "Senha deve conter letras e números";
    }

    return null;
  }

  int calcularForcaSenha(String senha) {
    int score = 0;

    if (senha.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(senha)) score++;
    if (RegExp(r'[0-9]').hasMatch(senha)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(senha)) score++;

    return score; // 0 até 4
  }

  // =============================
  // CONFIRMAR SENHA
  // =============================

  static String? confirmarSenha(String? value, String senhaOriginal) {
    if (value == null || value.isEmpty) {
      return "Confirme sua senha";
    }

    if (value != senhaOriginal) {
      return "As senhas não coincidem";
    }

    return null;
  }

  // =============================
  // TERMOS DE USO
  // =============================

  static String? termos(bool? value) {
    if (value == null || value == false) {
      return "Você precisa aceitar os termos";
    }
    return null;
  }
}
