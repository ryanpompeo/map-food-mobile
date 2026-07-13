import 'package:flutter/material.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/edit_profile_page_scaffold.dart';
import 'package:map_food/features/merchant/data/models/merchant_model.dart';
import 'package:map_food/features/merchant/data/services/merchant_service.dart';

class MerchantEditProfile extends StatefulWidget {
  const MerchantEditProfile({super.key});

  @override
  State<MerchantEditProfile> createState() => _MerchantEditProfileState();
}

class _MerchantEditProfileState extends State<MerchantEditProfile> {
  final _service = MerchantService();
  final _cnpjController = TextEditingController();
  MerchantModel? _original;

  @override
  void dispose() {
    _cnpjController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditProfilePageScaffold(
      sectionTitle: 'Dados do Comerciante',
      avatarFallbackLetter: 'C',
      fetchInitial: () async {
        final session = await AuthStorage.getSession();
        if (session == null) throw Exception('Sessão não encontrada');
        final data = await _service.getById(session.id);
        _original = data;
        _cnpjController.text = data.cnpj ?? '';
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
      extraFieldBuilder: (context) => AppFormField(
        label: 'CNPJ (opcional)',
        hint: 'XX.XXX.XXX/0001-XX',
        controller: _cnpjController,
        keyboardType: TextInputType.number,
      ),
      salvar: ({required nome, required email, required celular, novaSenha}) async {
        final original = _original!;
        final atualizado = MerchantModel(
          id: original.id,
          nome: nome,
          email: email,
          cpf: original.cpf,
          celular: celular,
          telefone: original.telefone,
          cnpj: _cnpjController.text.trim().isEmpty ? null : _cnpjController.text.trim(),
          imagemUrl: original.imagemUrl,
        );
        await _service.update(atualizado, novaSenha: novaSenha);
      },
    );
  }
}
