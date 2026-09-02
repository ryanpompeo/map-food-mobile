import 'package:flutter/material.dart';
import 'package:map_food/core/network/cep_service.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';

class StoreIdentityFields extends StatelessWidget {
  final TextEditingController nome;
  final TextEditingController descricao;

  final bool descricaoObrigatoria;

  const StoreIdentityFields({
    super.key,
    required this.nome,
    required this.descricao,
    this.descricaoObrigatoria = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppFormField(
          controller: nome,
          label: 'Nome do comércio',
          hint: 'Ex: Carrinho do João',
          icon: AppIcons.storefront,
          textInputAction: TextInputAction.next,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
        ),
        const SizedBox(height: Spacing.base),
        AppFormField(
          controller: descricao,
          label: descricaoObrigatoria ? 'Breve descrição' : 'Descrição',
          hint: 'Ex: Lanches e porções preparados na hora',
          icon: AppIcons.textAlignLeft,
          maxLines: 3,
          validator: descricaoObrigatoria
              ? (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null
              : null,
        ),
      ],
    );
  }
}

class StoreAddressFields extends StatefulWidget {
  final TextEditingController cep;
  final TextEditingController endereco;
  final TextEditingController cidade;
  final TextEditingController estado;

  final bool validarFormatoCep;

  final VoidCallback? onAutofill;

  const StoreAddressFields({
    super.key,
    required this.cep,
    required this.endereco,
    required this.cidade,
    required this.estado,
    this.validarFormatoCep = false,
    this.onAutofill,
  });

  @override
  State<StoreAddressFields> createState() => _StoreAddressFieldsState();
}

class _StoreAddressFieldsState extends State<StoreAddressFields> {
  final _cepService = CepService();
  bool _buscando = false;

  Future<void> _onCepChanged(String value) async {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8 || _buscando) return;

    setState(() => _buscando = true);
    final resultado = await _cepService.buscarEnderecoPorCep(digits);
    if (!mounted) return;

    setState(() {
      _buscando = false;
      if (resultado == null) return;
      if (resultado.logradouro?.isNotEmpty == true) {
        widget.endereco.text = resultado.logradouro!;
      }
      if (resultado.cidade?.isNotEmpty == true) {
        widget.cidade.text = resultado.cidade!;
      }
      if (resultado.uf?.isNotEmpty == true) {
        widget.estado.text = resultado.uf!;
      }
    });
    widget.onAutofill?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppFormField(
          controller: widget.cep,
          label: 'CEP',
          hint: '00000-000',
          icon: AppIcons.hash,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onChanged: _onCepChanged,
          suffixIcon: _buscando
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          validator: widget.validarFormatoCep
              ? (v) => v == null || v.isEmpty ? null : FormValidator.cep(v)
              : null,
        ),
        const SizedBox(height: Spacing.base),
        AppFormField(
          controller: widget.endereco,
          label: 'Rua e número',
          hint: 'Ex: Rua das Flores, 123',
          icon: AppIcons.mapPin,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: Spacing.base),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: AppFormField(
                controller: widget.cidade,
                label: 'Cidade',
                hint: 'Ex: Campinas',
                icon: AppIcons.buildingOffice,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: AppFormField(
                controller: widget.estado,
                label: 'UF',
                hint: 'SP',
                showIcon: false,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: (v) =>
                    v == null || v.trim().isEmpty || v.trim().length == 2 ? null : 'Inválido',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
