import 'package:flutter/material.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/widgets/edit_profile_page_scaffold.dart';
import 'package:map_food/features/consumer/data/models/consumer_model.dart';
import 'package:map_food/features/consumer/data/services/consumer_service.dart';

class ConsumerEditProfile extends StatefulWidget {
  const ConsumerEditProfile({super.key});

  @override
  State<ConsumerEditProfile> createState() => _ConsumerEditProfileState();
}

class _ConsumerEditProfileState extends State<ConsumerEditProfile> {
  final _service = ConsumerService();
  ConsumerModel? _original;

  @override
  Widget build(BuildContext context) {
    return EditProfilePageScaffold(
      sectionTitle: 'Meus Dados',
      avatarFallbackLetter: 'U',
      fetchInitial: () async {
        final session = await AuthStorage.getSession();
        if (session == null) throw Exception('Sessão não encontrada');
        final data = await _service.getById(session.id);
        _original = data;
        return (id: data.id, nome: data.nome, email: data.email, celular: data.celular, imagemUrl: data.imagemUrl);
      },
      uploadImagem: (id, file) async {
        final atualizado = await _service.uploadImagem(id, file);
        _original = atualizado;
        return atualizado.imagemUrl;
      },
      removerImagem: (id) async {
        final atualizado = await _service.removerImagem(id);
        _original = atualizado;
        return atualizado.imagemUrl;
      },
      salvar: ({required nome, required email, required celular, novaSenha}) async {
        final original = _original!;
        final atualizado = ConsumerModel(
          id: original.id,
          nome: nome,
          email: email,
          cpf: original.cpf,
          celular: celular,
          imagemUrl: original.imagemUrl,
        );
        await _service.update(atualizado, novaSenha: novaSenha);
      },
    );
  }
}
