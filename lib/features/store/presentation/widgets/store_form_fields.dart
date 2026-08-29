import 'package:flutter/material.dart';
import 'package:map_food/core/network/cep_service.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';

/// Os campos de loja que o cadastro e a edição preenchem — os mesmos dos dois
/// lados, agora escritos uma vez só.
///
/// Nasceu do mesmo problema que originou o `CategoryPicker`: cadastro e edição
/// mantinham cópias dos mesmos blocos, e cada ajuste feito de um lado deixava o
/// outro para trás (rótulos, ícones e validação já haviam divergido).

/// Nome e descrição — o que aparece no card da loja para o cliente.
class StoreIdentityFields extends StatelessWidget {
  final TextEditingController nome;
  final TextEditingController descricao;

  /// No cadastro a descrição é obrigatória (é a primeira impressão da loja);
  /// na edição, não — quem já tem loja publicada não pode ser impedido de
  /// salvar por um campo que estava vazio desde antes.
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

/// CEP, rua, cidade e UF — com o autofill do ViaCEP embutido.
///
/// O autofill mora aqui dentro, e não em cada tela: ele é comportamento **deste
/// bloco de campos**, não da página que o hospeda. Antes eram duas cópias da
/// mesma rotina (`_onCepChanged`), cada uma com seu `bool _buscandoCep` no
/// estado da tela, só para acender o mesmo spinner no mesmo campo.
class StoreAddressFields extends StatefulWidget {
  final TextEditingController cep;
  final TextEditingController endereco;
  final TextEditingController cidade;
  final TextEditingController estado;

  /// Valida o formato do CEP quando preenchido. O campo continua opcional nos
  /// dois fluxos — muitos comércios daqui são ambulantes, sem endereço fixo.
  final bool validarFormatoCep;

  /// Avisa a tela que algum campo mudou por autofill. Digitação já é ouvida
  /// pelos próprios controllers; o preenchimento automático não passa por eles
  /// como entrada do usuário, então quem controla "tem alterações não salvas"
  /// precisa deste aviso.
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

  /// Ao completar 8 dígitos, busca no ViaCEP e preenche rua/cidade/UF (tudo
  /// continua editável depois). Falha é silenciosa: quem digitou o CEP segue
  /// preenchendo à mão, sem um erro que não tem o que resolver.
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
