import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';

/// Foto selecionada localmente, ainda não enviada ao servidor.
/// Guarda os bytes (para pré-visualização com Image.memory, compatível com
/// Web) junto com o XFile original (necessário para o upload).
class _PickedPhoto {
  final XFile file;
  final Uint8List bytes;

  const _PickedPhoto(this.file, this.bytes);
}

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
  String? _errorMessage;
  bool _isLoading = false;

  final _storeService = StoreService();
  final _categoriaService = CategoriaService();
  final _picker = ImagePicker();

  // Foto Destaque (Capa)
  _PickedPhoto? _fotoDestaque;

  // Galeria Interna
  final List<_PickedPhoto> _fotosGaleria = [];
  final int _maxFotos = 10;

  final List<int> _categoriasSelecionadas = [];

  List<CategoriaModel> _categorias = [];
  bool _isLoadingCategorias = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) {
        setState(() {
          _categorias = categorias;
          _isLoadingCategorias = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCategorias = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFotoDestaque() async {
    final foto = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto == null) return;
    final bytes = await foto.readAsBytes();
    if (mounted) setState(() => _fotoDestaque = _PickedPhoto(foto, bytes));
  }

  Future<void> _adicionarFotoGaleria() async {
    final foto = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto == null) return;
    final bytes = await foto.readAsBytes();
    if (mounted) setState(() => _fotosGaleria.add(_PickedPhoto(foto, bytes)));
  }

  Future<void> _avancarEtapa() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_fotoDestaque == null) {
      _mostrarErro("Adicione uma Foto Destaque para o seu comércio");
      return;
    }

    if (_categoriasSelecionadas.isEmpty) {
      _mostrarErro("Selecione pelo menos uma categoria");
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

      final loja = await _storeService.create(request);

      // A loja já foi criada nesse ponto; falha ao enviar as fotos não deve
      // impedir o comerciante de seguir para o dashboard (ele pode reenviar
      // as fotos por lá depois).
      try {
        await _storeService.uploadImagemCapa(loja.id, _fotoDestaque!.file);
        if (_fotosGaleria.isNotEmpty) {
          await _storeService.uploadGaleria(
            loja.id,
            _fotosGaleria.map((p) => p.file).toList(),
          );
        }
      } catch (_) {
        // segue o fluxo mesmo se o upload de foto falhar
      }

      if (!mounted) return;

      // MerchantHomePage carrega os dados reais do banco automaticamente
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MerchantHomePage()),
        (route) => false,
      );
    } on AppException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Erro ao cadastrar loja. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: AppText.corpo(
            context,
          ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorsPalette.redComponents,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(),
        title: Text(
          "Configuração da Loja",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
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
                _buildFotoDestaque(),
                const SizedBox(height: AppSpacing.xl),

                _buildFotoUploadMulti(),
                const SizedBox(height: AppSpacing.xl),

                _buildTituloSecao("Dados Principais"),
                SizedBox(height: AppSpacing.md),
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
                  hint: "Ex: Lanches e porções preparados na hora...",
                  icon: LucideIcons.alignLeft,
                  maxLines: 3,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obrigatório' : null,
                ),

                const SizedBox(height: AppSpacing.xl),

                _buildTituloSecao("Categorias"),
                Text(
                  "Selecione o que você vende para os clientes te encontrarem mais fácil",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.greyText),
                ),
                const SizedBox(height: AppSpacing.md),

                if (_isLoadingCategorias)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: CircularProgressIndicator(
                        color: ColorsPalette.redComponents,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 12.0,
                    children: _categorias.map((cat) {
                      final isSelected = _categoriasSelecionadas.contains(
                        cat.id,
                      );
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _categoriasSelecionadas.remove(cat.id);
                            } else {
                              _categoriasSelecionadas.add(cat.id);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ColorsPalette.black
                                : Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            cat.nome,
                            style: AppText.corpo(context).copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : ColorsPalette.greyText,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          color: ColorsPalette.redComponents,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppText.corpo(context).copyWith(
                              color: ColorsPalette.redComponents,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                Container(
                  width: double.infinity,
                  height: 56.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    boxShadow: [
                      BoxShadow(
                        color: ColorsPalette.redComponents.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _avancarEtapa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorsPalette.redComponents,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          ColorsPalette.redComponents.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Concluir Cadastro",
                            style: AppText.botao(context).copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        titulo,
        style: AppText.subtitulo(
          context,
        ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
      ),
    );
  }

  Widget _buildFotoDestaque() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTituloSecao("Foto Destaque"),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                "Obrigatório",
                style: AppText.legenda(context).copyWith(
                  color: ColorsPalette.redComponents,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        Text(
          "Esta será a imagem principal da sua loja exibida nas buscas dos clientes",
          style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: _selecionarFotoDestaque,
          child: Container(
            height: 180.0,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _fotoDestaque != null
                  ? ColorsPalette.redComponents.withValues(alpha: 0.05)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: _fotoDestaque != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(_fotoDestaque!.bytes, fit: BoxFit.cover),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _fotoDestaque = null),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.trash2,
                              size: 16.0,
                              color: ColorsPalette.redComponents,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.imagePlus,
                          color: Colors.grey.shade500,
                          size: 28.0,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        "Adicionar Foto de Capa",
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorsPalette.black,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFotoUploadMulti() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSecao("Galeria Interna"),
        Text(
          "Adicione até $_maxFotos imagens para o seu cardápio ou vitrine",
          style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              if (_fotosGaleria.length < _maxFotos)
                GestureDetector(
                  onTap: _adicionarFotoGaleria,
                  child: Container(
                    height: 110.0,
                    width: 110.0,
                    margin: const EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      color: ColorsPalette.white,
                      borderRadius: BorderRadius.circular(20.0),

                      boxShadow: [
                        BoxShadow(
                          color: ColorsPalette.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: ColorsPalette.redComponents.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            color: ColorsPalette.redComponents,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Adicionar",
                          style: AppText.legenda(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: ColorsPalette.blackDetails,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ..._fotosGaleria.map((foto) => _buildFotoGaleriaItem(foto)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFotoGaleriaItem(_PickedPhoto foto) {
    return Container(
      height: 110.0,
      width: 110.0,
      margin: const EdgeInsets.only(right: 16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: ColorsPalette.redComponents.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(foto.bytes, fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() => _fotosGaleria.remove(foto));
              },
              child: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.x,
                  size: 14.0,
                  color: ColorsPalette.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
