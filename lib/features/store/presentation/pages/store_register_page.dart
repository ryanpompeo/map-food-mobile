import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/cep_service.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/core/ui/widgets/xfile_image.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';

class StoreRegisterPage extends StatefulWidget {
  const StoreRegisterPage({super.key});

  @override
  State<StoreRegisterPage> createState() => _StoreRegisterPageState();
}

class _StoreRegisterPageState extends State<StoreRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();

  final bool _statusLoja = true;
  String? _errorMessage;
  bool _isLoading = false;

  final _storeService = StoreService();
  final _categoriaService = CategoriaService();
  final _cepService = CepService();
  bool _buscandoCep = false;

  XFile? _fotoDestaque;

  final List<XFile> _fotosGaleria = [];
  final int _maxFotos = 10;

  static const int _maxCategorias = 3;
  final List<int> _categoriasSelecionadas = [];

  List<CategoriaModel> _categorias = [];
  bool _isLoadingCategorias = true;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    // Reconstrói a tela a cada tecla digitada para o PopScope do
    // UnsavedChangesGuard sempre enxergar o estado mais recente do
    // formulário ao decidir se deve pedir confirmação de saída.
    for (final controller in [
      _nomeController,
      _descricaoController,
      _enderecoController,
      _cidadeController,
      _estadoController,
      _cepController,
    ]) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() => setState(() {});

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
    for (final controller in [
      _nomeController,
      _descricaoController,
      _enderecoController,
      _cidadeController,
      _estadoController,
      _cepController,
    ]) {
      controller.removeListener(_onFormChanged);
    }
    _nomeController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  /// Converte o endereço digitado (opcional — muitos comércios daqui são
  /// ambulantes, sem endereço fixo) em lat/lng pra dar um ponto inicial no
  /// mapa. A posição de verdade vem do GPS ao vivo quando a loja fica
  /// "Aberta"/Em Ronda (ver `merchant_working_page.dart`); isso aqui é só um fallback
  /// pra quem quer indicar uma área de referência já no cadastro.
  Future<(double?, double?)> _geocodificarEndereco() async {
    // O pacote geocoding não tem implementação web.
    if (kIsWeb) return (null, null);
    if (_enderecoController.text.trim().isEmpty &&
        _cidadeController.text.trim().isEmpty) {
      return (null, null);
    }
    try {
      final query =
          '${_enderecoController.text.trim()}, '
          '${_cidadeController.text.trim()} - ${_estadoController.text.trim()}, Brasil';
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isEmpty) return (null, null);
      return (locations.first.latitude, locations.first.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  /// Autofill: ao completar 8 dígitos de CEP, busca no ViaCEP e preenche
  /// rua/cidade/UF (o usuário pode editar depois). Falha é silenciosa.
  Future<void> _onCepChanged(String value) async {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8 || _buscandoCep) return;

    setState(() => _buscandoCep = true);
    final resultado = await _cepService.buscarEnderecoPorCep(digits);
    if (!mounted) return;

    setState(() {
      _buscandoCep = false;
      if (resultado != null) {
        if (resultado.logradouro?.isNotEmpty == true) {
          _enderecoController.text = resultado.logradouro!;
        }
        if (resultado.cidade?.isNotEmpty == true) {
          _cidadeController.text = resultado.cidade!;
        }
        if (resultado.uf?.isNotEmpty == true) {
          _estadoController.text = resultado.uf!;
        }
      }
    });
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
      final (latitude, longitude) = await _geocodificarEndereco();

      final request = StoreCreateRequest(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        statusLoja: _statusLoja ? 'ATIVA' : 'INATIVA',
        categoriaIds: List<int>.from(_categoriasSelecionadas),
        endereco: _enderecoController.text.trim().isEmpty
            ? null
            : _enderecoController.text.trim(),
        cidade: _cidadeController.text.trim().isEmpty
            ? null
            : _cidadeController.text.trim(),
        estado: _estadoController.text.trim().isEmpty
            ? null
            : _estadoController.text.trim().toUpperCase(),
        cep: _cepController.text.trim().isEmpty
            ? null
            : _cepController.text.trim(),
        latitude: latitude,
        longitude: longitude,
      );

      final loja = await _storeService.create(request);

      try {
        await _storeService.uploadImagemCapa(loja.id, _fotoDestaque!);
        if (_fotosGaleria.isNotEmpty) {
          await _storeService.uploadGaleria(loja.id, _fotosGaleria);
        }
      } catch (_) {
        if (mounted) {
          AppToast.error(
            context,
            'Loja cadastrada, mas houve um erro ao enviar as fotos. Tente novamente na edição da loja.',
          );
        }
      }

      if (!mounted) return;

      // MerchantHomePage carrega os dados reais do banco automaticamente
      Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (_) => const MerchantHomePage()),
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
    AppToast.error(context, mensagem);
  }

  bool get _hasUnsavedChanges =>
      _nomeController.text.isNotEmpty ||
      _descricaoController.text.isNotEmpty ||
      _enderecoController.text.isNotEmpty ||
      _cidadeController.text.isNotEmpty ||
      _estadoController.text.isNotEmpty ||
      _cepController.text.isNotEmpty ||
      _fotoDestaque != null ||
      _fotosGaleria.isNotEmpty ||
      _categoriasSelecionadas.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
        backgroundColor: context.mapColors.mainBackground,
        appBar: AppBar(
          backgroundColor: context.mapColors.mainBackground,
          foregroundColor: context.mapColors.primaryText,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: Container(),
          title: Text(
            "Configuração da Loja",
            style: AppText.subtitulo(
              context,
            ).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
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
                    icon: PhosphorIconsRegular.storefront,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    controller: _descricaoController,
                    label: "Breve descrição",
                    hint: "Ex: Lanches e porções preparados na hora...",
                    icon: PhosphorIconsRegular.textAlignLeft,
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obrigatório' : null,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _buildTituloSecao("Endereço (opcional)"),
                  Text(
                    "Sua loja aparece no mapa pela localização em tempo real quando você ativa 'Loja Aberta' — não precisa de endereço fixo. Preencha aqui só se quiser indicar uma área de referência.",
                    style: AppText.corpo(
                      context,
                    ).copyWith(color: context.mapColors.secondaryText),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    controller: _cepController,
                    label: "CEP (preenche o endereço sozinho)",
                    hint: "00000-000",
                    icon: PhosphorIconsRegular.hash,
                    keyboardType: TextInputType.number,
                    onChanged: _onCepChanged,
                    suffixIcon: _buscandoCep
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorsPalette.redComponents,
                              ),
                            ),
                          )
                        : null,
                    validator: (v) =>
                        v == null || v.isEmpty ? null : FormValidator.cep(v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    controller: _enderecoController,
                    label: "Rua e número",
                    hint: "Ex: Rua das Flores, 123",
                    icon: PhosphorIconsRegular.mapPin,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppFormField(
                          controller: _cidadeController,
                          label: "Cidade",
                          hint: "Ex: Campinas",
                          icon: PhosphorIconsRegular.buildingOffice,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 1,
                        child: AppFormField(
                          controller: _estadoController,
                          label: "UF",
                          hint: "SP",
                          showIcon: false,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) =>
                              v == null ||
                                  v.trim().isEmpty ||
                                  v.trim().length == 2
                              ? null
                              : 'Inválido',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _buildTituloSecao("Categorias"),
                  Text(
                    "Selecione o que você vende para os clientes te encontrarem mais fácil",
                    style: AppText.corpo(
                      context,
                    ).copyWith(color: context.mapColors.secondaryText),
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
                            if (!isSelected &&
                                _categoriasSelecionadas.length >=
                                    _maxCategorias) {
                              AppToast.error(
                                context,
                                'Escolha no máximo $_maxCategorias categorias.',
                              );
                              return;
                            }
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
                              // Chip flutuante sobre a página — cardSurface
                              // quando não selecionado; selecionado fica
                              // sólido preto de propósito (CTA do Lote 1).
                              color: isSelected
                                  ? ColorsPalette.black
                                  : context.mapColors.cardSurface,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Text(
                              cat.nome,
                              style: AppText.corpo(context).copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : context.mapColors.secondaryText,
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
                        color: ColorsPalette.redComponents.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            PhosphorIconsRegular.info,
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
                        disabledBackgroundColor: ColorsPalette.redComponents
                            .withValues(alpha: 0.6),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
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
        ).copyWith(fontWeight: FontWeight.w900, color: context.mapColors.primaryText),
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
          style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () async {
            final file = await pickImageFromSheet(context);
            if (file != null) setState(() => _fotoDestaque = file);
          },
          child: Container(
            height: 180.0,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // Estado vazio: superfície flutuante sobre a página. Estado
              // preenchido mantém o tingimento de marca, intocado.
              color: _fotoDestaque != null
                  ? ColorsPalette.redComponents.withValues(alpha: 0.05)
                  : context.mapColors.cardSurface,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: _fotoDestaque != null
                ? Stack(
                    children: [
                      Positioned.fill(child: XFileImage(_fotoDestaque!)),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _fotoDestaque = null),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            // Botão flutuante sobre a foto do usuário —
                            // cardSurface, não Colors.white literal.
                            decoration: BoxDecoration(
                              color: context.mapColors.cardSurface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              PhosphorIconsRegular.trash,
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
                        // Um tom abaixo do cardSurface do container que
                        // envolve este ícone (mesmo padrão de superfície
                        // aninhada do Lote 4A/2).
                        decoration: BoxDecoration(
                          color: context.mapColors.mainBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsRegular.imagesSquare,
                          color: context.mapColors.iconMuted,
                          size: 28.0,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        "Adicionar Foto de Capa",
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.mapColors.primaryText,
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
          style: AppText.corpo(context).copyWith(color: context.mapColors.secondaryText),
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
                  onTap: () async {
                    final file = await pickImageFromSheet(context);
                    if (file != null) setState(() => _fotosGaleria.add(file));
                  },
                  child: Container(
                    height: 110.0,
                    width: 110.0,
                    margin: const EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      // Tile flutuante sobre a página — cardSurface.
                      color: context.mapColors.cardSurface,
                      borderRadius: BorderRadius.circular(20.0),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
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
                            PhosphorIconsRegular.camera,
                            color: ColorsPalette.redComponents,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "Adicionar",
                          style: AppText.legenda(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.mapColors.primaryText,
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

  Widget _buildFotoGaleriaItem(XFile foto) {
    return Container(
      height: 110.0,
      width: 110.0,
      margin: const EdgeInsets.only(right: 16.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ColorsPalette.redComponents.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: ColorsPalette.redComponents.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: XFileImage(foto)),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() => _fotosGaleria.remove(foto));
              },
              child: Container(
                padding: const EdgeInsets.all(6.0),
                // Botão flutuante sobre a foto do usuário — cardSurface.
                decoration: BoxDecoration(
                  color: context.mapColors.cardSurface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  PhosphorIconsRegular.x,
                  size: 14.0,
                  color: context.mapColors.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
