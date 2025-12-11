class Usuario {
  String? uid;
  String? nome;
  String? email;
  String? tipo; // "cliente" ou "vendedor"
  List<String>? favoritos; // lista de IDs de lojas favorited

  Usuario({
    this.uid,
    this.nome,
    this.email,
    this.tipo,
    this.favoritos,
  });

  Usuario.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    nome = json['nome'];
    email = json['email'];
    tipo = json['tipo'];
    favoritos = json['favoritos'] != null
        ? List<String>.from(json['favoritos'])
        : [];
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'favoritos': favoritos,
    };
  }
}
