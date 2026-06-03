import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/core/widgets/app_form_field.dart';

class StoreRegisterPage extends StatefulWidget {
  const StoreRegisterPage({super.key});

  @override
  State<StoreRegisterPage> createState() => _StoreRegisterPageState();
}

class _StoreRegisterPageState extends State<StoreRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeLojaController = TextEditingController();
  final _descricaoController = TextEditingController();

  @override
  void dispose() {
    _nomeLojaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _criarLoja() {
    if (!_formKey.currentState!.validate()) return;

    debugPrint("Aguardando nova API... Payload de Loja pronto:");
    debugPrint("Nome: ${_nomeLojaController.text.trim()}");
    debugPrint("Descrição: ${_descricaoController.text.trim()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.whiteBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            LucideIcons.chevronLeft,
            color: ColorsPalette.redComponents,
            size: AppIconSize.lg,
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
                Text(
                  "Cadastre\nsua Loja",
                  style: AppText.display(context).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    color: ColorsPalette.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Configure o perfil do seu estabelecimento para aparecer no mapa aos clientes.",
                  style: AppText.secundario(
                    context,
                  ).copyWith(fontSize: 15.0, height: 1.4),
                ),

                const SizedBox(height: AppSpacing.xl),

                AppFormField(
                  controller: _nomeLojaController,
                  label: "Nome do Estabelecimento",
                  hint: "Ex: Hamburgueria do Zé",
                  icon: LucideIcons.store,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.isEmpty
                      ? 'O nome da loja é obrigatório'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),

                AppFormField(
                  controller: _descricaoController,
                  label: "Descrição da Loja",
                  hint: "Descreva seus principais produtos e diferenciais...",
                  icon: LucideIcons.alignLeft,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) => value == null || value.length < 10
                      ? 'Forneça uma descrição com pelo menos 10 caracteres'
                      : null,
                ),

                const SizedBox(height: AppSpacing.xxl),

                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _criarLoja,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.redComponents,
                      foregroundColor: ColorsPalette.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Finalizar Cadastro da Loja",
                      style: AppText.botao(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
