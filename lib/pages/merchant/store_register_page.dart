import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/widgets/app_form_field.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class StoreRegisterPage extends StatefulWidget {
  const StoreRegisterPage({super.key});

  @override
  State<StoreRegisterPage> createState() => _StoreRegisterPageState();
}

class _StoreRegisterPageState extends State<StoreRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _complementoController = TextEditingController();

  bool _lojaAtiva = true;
  bool _hasFoto = false;
  bool _isLoading = false;

  final _cepFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _cepController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  void _cadastrarLoja() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: ColorsPalette.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Registre seu negócio",
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: ColorsPalette.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSecaoFoto(),
                const SizedBox(height: AppSpacing.xl),

                _buildTituloSecao("Dados Principais"),
                AppFormField(
                  controller: _nomeController,
                  label: "Nome do Estabelecimento",
                  hint: "Ex: Hamburgueria Central",
                  icon: LucideIcons.store,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppFormField(
                  controller: _descricaoController,
                  label: "Descrição",
                  hint: "Ex: Lanches e porções artesanais",
                  icon: LucideIcons.alignLeft,
                  maxLines: 2,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: AppSpacing.xl),
                _buildTituloSecao("Endereço"),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppFormField(
                        controller: _cepController,
                        label: "CEP",
                        hint: "00000-000",
                        icon: LucideIcons.mapPin,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cepFormatter],
                        validator: (v) =>
                            v == null || v.length < 9 ? 'Inválido' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 1,
                      child: AppFormField(
                        controller: _estadoController,
                        label: "UF",
                        hint: "SP",
                        textCapitalization: TextCapitalization.characters,
                        showIcon: false,
                        validator: (v) => v == null || v.isEmpty ? 'Er' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _ruaController,
                  label: "Rua / Avenida",
                  hint: "Ex: Avenida Laranjeiras",
                  icon: LucideIcons.map,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppFormField(
                        controller: _numeroController,
                        label: "Número",
                        hint: "123",
                        keyboardType: TextInputType.number,
                        showIcon: false,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: AppFormField(
                        controller: _complementoController,
                        label: "Complemento",
                        hint: "Ex: Sala 2 / Casa",
                        showIcon: false,
                        validator: (v) => null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppFormField(
                        controller: _bairroController,
                        label: "Bairro",
                        hint: "Centro",
                        showIcon: false,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppFormField(
                        controller: _cidadeController,
                        label: "Cidade",
                        hint: "Limeira",
                        showIcon: false,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
                _buildStatusSwitch(),

                const SizedBox(height: AppSpacing.xxl),
                _buildBotaoSalvar(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTituloSecao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        titulo,
        style: AppText.subtitulo(
          context,
        ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
      ),
    );
  }

  Widget _buildSecaoFoto() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _hasFoto = !_hasFoto),
        child: Container(
          height: 100.0,
          width: 100.0,
          decoration: BoxDecoration(
            color: _hasFoto
                ? ColorsPalette.blackComponents
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _hasFoto
                  ? ColorsPalette.blackComponents
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _hasFoto ? LucideIcons.checkCircle : LucideIcons.camera,
                color: _hasFoto ? Colors.white : Colors.grey.shade500,
                size: AppIconSize.lg,
              ),
              if (!_hasFoto) ...[
                const SizedBox(height: 4.0),
                Text(
                  "Logo",
                  style: AppText.legenda(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SwitchListTile(
        title: Text(
          "Disponível no Mapa",
          style: AppText.corpo(
            context,
          ).copyWith(fontWeight: FontWeight.w700, color: ColorsPalette.black),
        ),
        subtitle: Text(
          "Ativa a visibilidade imediata da loja no mapa.",
          style: AppText.legenda(context).copyWith(color: Colors.grey.shade600),
        ),
        value: _lojaAtiva,
        activeColor: ColorsPalette.whiteBackground,
        activeTrackColor: ColorsPalette.redComponents,
        inactiveThumbColor: Colors.grey.shade400,
        inactiveTrackColor: Colors.grey.shade200,
        onChanged: (bool value) => setState(() => _lojaAtiva = value),
      ),
    );
  }

  Widget _buildBotaoSalvar() {
    return SizedBox(
      width: double.infinity,
      height: 52.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _cadastrarLoja,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsPalette.redComponents,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ColorsPalette.redComponents.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
          textStyle: AppText.botao(context),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text("Concluir Cadastro"),
      ),
    );
  }
}
