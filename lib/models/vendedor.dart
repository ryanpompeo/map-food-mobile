class Vendedor {
  String? uid;        // mesmo uid do Firebase Auth
  String? nome;       // puxado do Usuario
  String? cnpj;       // opcional
  String? telefone;
  List<int>? lojas;   // lista de IDs das lojas que ele possui

  Vendedor({
    this.uid,
    this.nome,
    this.cnpj,
    this.telefone,
    this.lojas,
  });

  Vendedor.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    nome = json['nome'];
    cnpj = json['cnpj'];
    telefone = json['telefone'];
    lojas = json['lojas'] != null
        ? List<int>.from(json['lojas'])
        : [];
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'cnpj': cnpj,
      'telefone': telefone,
      'lojas': lojas,
    };
  }
}
