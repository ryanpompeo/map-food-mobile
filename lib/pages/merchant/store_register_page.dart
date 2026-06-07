import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/errors/app_exception.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/models/store/store_create_request.dart';
import 'package:map_food/pages/auth/widgets/app_form_field.dart';
import 'package:map_food/pages/merchant/merchant_home_page.dart';

class StoreRegisterPage extends StatefulWidget {
  const StoreRegisterPage({super.key});

  @override
  State<StoreRegisterPage> createState() => _StoreRegisterPageState();
}

class _StoreRegisterPageState extends State<StoreRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  final bool _statusLoja = true;
  bool _isLoading = false;
  String? _errorMessage;

  final List<int> _fotosMock = [];
  final int _maxFotos = 3;

  final List<int> _categoriasSelecionadas = [];
  final List<Map<String, dynamic>> _categoriasBase = [
    {'id': 1, 'nome': 'Salgados'},
    {'id': 2, 'nome': 'Doces'},
    {'id': 3, 'nome': 'Bebidas'},
    {'id': 4, 'nome': 'Marmitas'},
    {'id': 5, 'nome': 'Vegano'},
    {'id': 6, 'nome': 'Espetinhos'},
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _cadastrarLoja() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriasSelecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione pelo menos uma categoria."),
          backgroundColor: ColorsPalette.redComponents,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final request = StoreCreateRequest(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        statusLoja: _statusLoja ? 'ATIVA' : 'INATIVA',
        categoriaIds: List<int>.from(_categoriasSelecionadas),
      );

      debugPrint("=== ENVIANDO PARA API ===");
      debugPrint(request.toJson().toString());

      if (!mounted) return;

      debugPrint(
        "Loja cadastrada! Redirecionando para o Dashboard do Comerciante.",
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MerchantHomePage()),
      );
    } on AppException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          "Configuração da Loja",
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
                const SizedBox(height: AppSpacing.sm),
                _buildFotoUploadMulti(),
                const SizedBox(height: AppSpacing.xl),

                _buildTituloSecao("Dados Principais"),
                AppFormField(
                  controller: _nomeController,
                  label: "Nome do Comércio",
                  hint: "Ex: Carrinho do João",
                  icon: LucideIcons.store,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppFormField(
                  controller: _descricaoController,
                  label: "Breve descrição",
                  hint: "Ex: Lanches e porções",
                  icon: LucideIcons.alignLeft,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: AppSpacing.xl),

                _buildTituloSecao("Categorias de Produtos"),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _categoriasBase.map((cat) {
                    final isSelected = _categoriasSelecionadas.contains(
                      cat['id'],
                    );
                    return ChoiceChip(
                      label: Text(
                        cat['nome'],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : ColorsPalette.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: ColorsPalette.redComponents,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        side: BorderSide(
                          color: isSelected
                              ? ColorsPalette.redComponents
                              : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _categoriasSelecionadas.add(cat['id']);
                          } else {
                            _categoriasSelecionadas.remove(cat['id']);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrarLoja,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.redComponents,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: ColorsPalette.redComponents
                          .withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Concluir Configuração",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
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
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildFotoUploadMulti() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSecao("Fotos do Estabelecimento"),
        Text(
          "Adicione até $_maxFotos imagens para sua vitrine.",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14.0),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              if (_fotosMock.length < _maxFotos)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _fotosMock.add(DateTime.now().millisecondsSinceEpoch);
                    });
                  },
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.camera,
                          color: Colors.grey.shade500,
                          size: 28.0,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          "Adicionar",
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ..._fotosMock.map((fotoId) => _buildFotoMockItem(fotoId)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFotoMockItem(int fotoId) {
    return Container(
      height: 100.0,
      width: 100.0,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        color: ColorsPalette.redComponents.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: ColorsPalette.redComponents, width: 1.5),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              LucideIcons.image,
              color: ColorsPalette.redComponents,
              size: AppSpacing.xl,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() => _fotosMock.remove(fotoId));
              },
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(
                  LucideIcons.trash2,
                  size: 14.0,
                  color: ColorsPalette.redComponents,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
