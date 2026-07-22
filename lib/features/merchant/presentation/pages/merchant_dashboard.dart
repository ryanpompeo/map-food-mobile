import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:map_food/core/network/cep_service.dart';
import 'package:map_food/core/network/image_url_resolver.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/xfile_image.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class MerchantDashboard extends StatefulWidget {
  final StoreDto store;

  /// Barra de troca de loja (comerciante com mais de uma loja) — opcional.
  final Widget? storeSwitcher;

  /// Notifica o pai quando a loja é alterada no backend (edição salva),
  /// pra lista de lojas dele não ficar defasada.
  final ValueChanged<StoreDto>? onStoreUpdated;

  const MerchantDashboard({
    super.key,
    required this.store,
    this.storeSwitcher,
    this.onStoreUpdated,
  });

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isRemovendoCapa = false;
  String? _removendoGaleriaUrl;

  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _enderecoController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _cepController;
  static const int _maxCategorias = 3;
  late List<int> _categoriasSelecionadas;

  // Foto de capa/galeria já salvas no servidor (`_store.capaUrl`/`galeria`) são
  // só exibidas; estas variáveis guardam fotos escolhidas nesta sessão de
  // edição, que ainda não foram enviadas.
  XFile? _novaCapa;
  final List<XFile> _novasFotosGaleria = [];

  late StoreDto _store;

  final int _maxFotosGaleria = 10;
  final _storeService = StoreService();
  final _categoriaService = CategoriaService();
  final _avaliacaoService = AvaliacaoService();
  final _cepService = CepService();
  bool _buscandoCep = false;

  List<CategoriaModel> _categorias = [];
  bool _isLoadingCategorias = true;

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingAvaliacoes = true;

  // Agregação de avaliação vinda do backend (Fase 4) — não é mais calculada
  // no cliente a partir de `_avaliacoes`.
  double? _mediaAvaliacao;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
    _carregarCategorias();
    _carregarAvaliacoes();
    _carregarMediaAvaliacao();
  }

  Future<void> _carregarMediaAvaliacao() async {
    try {
      final resumo = await _storeService.getResumo(widget.store.id);
      if (mounted) setState(() => _mediaAvaliacao = resumo.avaliacao);
    } catch (_) {
      // Mantém null ("Novo") se a busca falhar.
    }
  }

  void _inicializarDados() {
    _store = widget.store;
    _nomeController = TextEditingController(text: widget.store.nome);
    _descricaoController = TextEditingController(
      text: widget.store.descricao ?? '',
    );
    _enderecoController = TextEditingController(
      text: widget.store.endereco ?? '',
    );
    _cidadeController = TextEditingController(text: widget.store.cidade ?? '');
    _estadoController = TextEditingController(text: widget.store.estado ?? '');
    _cepController = TextEditingController(text: widget.store.cep ?? '');
    _categoriasSelecionadas = List.from(widget.store.categoriaIds);
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

  Future<void> _carregarAvaliacoes() async {
    try {
      final avaliacoes = await _avaliacaoService.buscarAvaliacoesDaLoja(widget.store.id);
      if (mounted) {
        setState(() {
          _avaliacoes = avaliacoes;
          _isLoadingAvaliacoes = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAvaliacoes = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  /// Converte o endereço digitado (opcional — a posição de verdade vem do
  /// GPS ao vivo quando a loja fica "Aberta"/Em Ronda) em lat/lng, como um
  /// ponto de referência inicial. Se falhar, salva mesmo assim.
  Future<(double?, double?)> _geocodificarEndereco() async {
    // O pacote geocoding não tem implementação web.
    if (kIsWeb) return (null, null);
    if (_enderecoController.text.trim().isEmpty && _cidadeController.text.trim().isEmpty) {
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

  void _abrirModalConfirmacao() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        backgroundColor: context.mapColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  PhosphorIconsRegular.checkCircle,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Salvar Alterações",
                style: AppText.titulo(
                  context,
                ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Deseja confirmar e atualizar as informações públicas da sua loja?",
                textAlign: TextAlign.center,
                style: AppText.corpo(
                  context,
                ).copyWith(color: context.mapColors.secondaryText),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: context.mapColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: AppText.botao(
                          context,
                        ).copyWith(color: context.mapColors.primaryText),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _efetivarSalvamento();
                      },
                      style: ElevatedButton.styleFrom(
                        // CTA sólido preto de propósito (Lote 1), não tokenizado.
                        backgroundColor: ColorsPalette.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removerCapaSalva() async {
    if (_store.capaUrl == null) return;
    final confirmou = await confirmarRemocaoFoto(context);
    if (!confirmou || !mounted) return;

    setState(() => _isRemovendoCapa = true);
    try {
      final atualizada = await _storeService.removerImagemCapa(widget.store.id);
      if (mounted) setState(() => _store = atualizada);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, "Não foi possível remover a foto. Tente novamente.");
      }
    } finally {
      if (mounted) setState(() => _isRemovendoCapa = false);
    }
  }

  Future<void> _removerFotoGaleriaSalva(String url) async {
    final confirmou = await confirmarRemocaoFoto(context);
    if (!confirmou || !mounted) return;

    setState(() => _removendoGaleriaUrl = url);
    try {
      final atualizada = await _storeService.removerFotoGaleria(
        widget.store.id,
        url,
      );
      if (mounted) setState(() => _store = atualizada);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, "Não foi possível remover a foto. Tente novamente.");
      }
    } finally {
      if (mounted) setState(() => _removendoGaleriaUrl = null);
    }
  }

  Future<void> _efetivarSalvamento() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final enderecoMudou =
          _enderecoController.text.trim() != (widget.store.endereco ?? '') ||
          _cidadeController.text.trim() != (widget.store.cidade ?? '') ||
          _estadoController.text.trim() != (widget.store.estado ?? '');

      double? latitude;
      double? longitude;
      if (enderecoMudou && _enderecoController.text.trim().isNotEmpty) {
        (latitude, longitude) = await _geocodificarEndereco();
      }

      final request = StoreCreateRequest(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
        statusLoja: widget.store.statusLoja,
        categoriaIds: List.from(_categoriasSelecionadas),
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

      var lojaAtualizada = await _storeService.update(widget.store.id, request);

      if (_novaCapa != null) {
        lojaAtualizada = await _storeService.uploadImagemCapa(
          widget.store.id,
          _novaCapa!,
        );
      }
      if (_novasFotosGaleria.isNotEmpty) {
        lojaAtualizada = await _storeService.uploadGaleria(
          widget.store.id,
          _novasFotosGaleria,
        );
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          _store = lojaAtualizada;
          _novaCapa = null;
          _novasFotosGaleria.clear();
        });
        widget.onStoreUpdated?.call(lojaAtualizada);
        AppToast.success(context, "Informações atualizadas com sucesso!");
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, "Erro ao salvar. Tente novamente.");
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _cancelarEdicao() {
    setState(() {
      _isEditing = false;
      _nomeController.text = widget.store.nome;
      _descricaoController.text = widget.store.descricao ?? '';
      _enderecoController.text = widget.store.endereco ?? '';
      _cidadeController.text = widget.store.cidade ?? '';
      _estadoController.text = widget.store.estado ?? '';
      _cepController.text = widget.store.cep ?? '';
      _categoriasSelecionadas = List.from(widget.store.categoriaIds);
      _novaCapa = null;
      _novasFotosGaleria.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.mapColors.mainBackground,
      body: Column(
        children: [
          if (widget.storeSwitcher != null)
            SafeArea(bottom: false, child: widget.storeSwitcher!),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Perfil da Loja",
                          style: AppText.titulo(
                            context,
                          ).copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (!_isEditing)
                        GestureDetector(
                          onTap: () => setState(() => _isEditing = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // Scrim sutil na cor do texto (não um literal
                              // fixo) — inverte corretamente entre claro/escuro.
                              color: context.mapColors.primaryText.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIconsRegular.pencilSimple,
                                  size: 16,
                                  color: context.mapColors.primaryText,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Editar",
                                  style: AppText.legenda(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.mapColors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        TextButton(
                          onPressed: _cancelarEdicao,
                          child: Text(
                            "Cancelar",
                            style: AppText.legenda(context).copyWith(
                              color: ColorsPalette.redComponents,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  _buildSecaoFotos(),
                  const SizedBox(height: AppSpacing.xl),

                  _buildCampoTexto(
                    "Nome do Comércio",
                    _nomeController,
                    isMultiline: false,
                  ),
                  _buildCampoTexto(
                    "Descrição",
                    _descricaoController,
                    isMultiline: true,
                  ),
                  Text(
                    "Endereço (opcional) — sua loja aparece no mapa pela localização em tempo real quando está \"Aberta\", não precisa de endereço fixo",
                    style: AppText.legenda(context).copyWith(color: ColorsPalette.greyText),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCampoTexto(
                    "CEP (preenche o endereço sozinho)",
                    _cepController,
                    isMultiline: false,
                    onChanged: _onCepChanged,
                    suffixIcon: _buscandoCep
                        ? const Padding(
                            padding: EdgeInsets.all(14.0),
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
                  ),
                  _buildCampoTexto(
                    "Endereço (rua e número)",
                    _enderecoController,
                    isMultiline: false,
                  ),
                  _buildCampoTexto(
                    "Cidade",
                    _cidadeController,
                    isMultiline: false,
                  ),
                  _buildCampoTexto("UF", _estadoController, isMultiline: false),
                  const SizedBox(height: AppSpacing.md),

                  _buildCategoriasSection(),

                  const SizedBox(height: AppSpacing.xxl),
                  const Divider(thickness: 0.5),
                  const SizedBox(height: AppSpacing.lg),

                  _buildAvaliacoesSection(),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: _isEditing
          ? Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: FloatingActionButton.extended(
                onPressed: _isSaving ? null : _abrirModalConfirmacao,
                backgroundColor: _isSaving
                    ? Colors.grey
                    : ColorsPalette.redComponents,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        PhosphorIconsRegular.floppyDisk,
                        color: Colors.white,
                        size: 20,
                      ),
                label: Text(
                  _isSaving ? "Salvando..." : "Salvar Mudanças",
                  style: AppText.botao(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
    );
  }

  Widget _buildSecaoFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Foto de Destaque",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _isEditing
              ? () async {
                  final file = await pickImageFromSheet(context);
                  if (file != null) setState(() => _novaCapa = file);
                }
              : null,
          child: Container(
            height: 160.0,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _novaCapa != null || _store.capaUrl != null
                  ? ColorsPalette.redComponents.withValues(alpha: 0.05)
                  : context.mapColors.cardSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: _isEditing
                    ? ColorsPalette.redComponents.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: _novaCapa != null || resolveImagemUrl(_store.capaUrl) != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      _novaCapa != null
                          ? XFileImage(_novaCapa!)
                          : Image.network(
                              resolveImagemUrl(_store.capaUrl)!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      PhosphorIconsRegular.image,
                                      color: ColorsPalette.redComponents,
                                      size: 48.0,
                                    ),
                                  ),
                            ),
                      if (_isEditing)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _isRemovendoCapa
                                ? null
                                : _novaCapa != null
                                ? () => setState(() => _novaCapa = null)
                                : _removerCapaSalva,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: context.mapColors.cardSurface,
                                shape: BoxShape.circle,
                              ),
                              child: _isRemovendoCapa
                                  ? const SizedBox(
                                      width: 16.0,
                                      height: 16.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ColorsPalette.redComponents,
                                      ),
                                    )
                                  : const Icon(
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
                      Icon(
                        PhosphorIconsRegular.imagesSquare,
                        color: context.mapColors.iconMuted,
                        size: 32.0,
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          "Adicionar Capa",
                          style: AppText.legenda(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Text(
          "Galeria (${_store.galeria.length + _novasFotosGaleria.length}/$_maxFotosGaleria)",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              if (_isEditing &&
                  (_store.galeria.length + _novasFotosGaleria.length) <
                      _maxFotosGaleria)
                GestureDetector(
                  onTap: () async {
                    final file = await pickImageFromSheet(context);
                    if (file != null)
                      setState(() => _novasFotosGaleria.add(file));
                  },
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      color: context.mapColors.cardSurface,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          PhosphorIconsRegular.plus,
                          color: ColorsPalette.redComponents,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          "Adicionar",
                          style: AppText.legenda(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ..._store.galeria.map((fotoPath) {
                final url = resolveImagemUrl(fotoPath);
                final removendo = _removendoGaleriaUrl == fotoPath;
                return Container(
                  height: 100.0,
                  width: 100.0,
                  margin: const EdgeInsets.only(right: 12.0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: context.mapColors.cardSurface,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: url != null
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        PhosphorIconsRegular.image,
                                        color: context.mapColors.iconMuted,
                                        size: 32.0,
                                      ),
                                    ),
                              )
                            : Center(
                                child: Icon(
                                  PhosphorIconsRegular.image,
                                  color: context.mapColors.iconMuted,
                                  size: 32.0,
                                ),
                              ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: removendo
                                ? null
                                : () => _removerFotoGaleriaSalva(fotoPath),
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: context.mapColors.cardSurface,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.mapColors.border),
                              ),
                              child: removendo
                                  ? const SizedBox(
                                      width: 12.0,
                                      height: 12.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ColorsPalette.redComponents,
                                      ),
                                    )
                                  : Icon(
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
              }),
              ..._novasFotosGaleria.map((foto) {
                return Container(
                  height: 100.0,
                  width: 100.0,
                  margin: const EdgeInsets.only(right: 12.0),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: context.mapColors.cardSurface,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(child: XFileImage(foto)),
                      if (_isEditing)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _novasFotosGaleria.remove(foto)),
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: context.mapColors.cardSurface,
                                shape: BoxShape.circle,
                                border: Border.all(color: context.mapColors.border),
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
              }),
              if (!_isEditing &&
                  _store.galeria.isEmpty &&
                  _novasFotosGaleria.isEmpty)
                // Sem override de cor: legenda() já resolve pra secondaryText.
                Text(
                  "Nenhuma foto na galeria.",
                  style: AppText.legenda(context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampoTexto(
    String label,
    TextEditingController controller, {
    required bool isMultiline,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.subtitulo(
              context,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            maxLines: isMultiline ? 3 : 1,
            readOnly: !_isEditing,
            onChanged: _isEditing ? onChanged : null,
            style: AppText.corpo(context).copyWith(
              color: _isEditing ? context.mapColors.primaryText : context.mapColors.secondaryText,
              fontWeight: _isEditing ? FontWeight.normal : FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditing ? context.mapColors.cardSurface : context.mapColors.mainBackground,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide(
                  // Somente-leitura: borda "invisível", emparelhada com o
                  // mesmo tom do fillColor acima — não usar o token `border`
                  // aqui criaria um contorno visível que não existia antes.
                  color: _isEditing
                      ? ColorsPalette.redComponents.withValues(alpha: 0.3)
                      : context.mapColors.mainBackground,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide(
                  color: _isEditing ? context.mapColors.border : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: const BorderSide(
                  color: ColorsPalette.redComponents,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Categorias",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_isLoadingCategorias)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: CircularProgressIndicator(
              color: ColorsPalette.redComponents,
              strokeWidth: 2,
            ),
          )
        else
          Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            children: _categorias.map((cat) {
              final isSelected = _categoriasSelecionadas.contains(cat.id);

              if (!_isEditing && !isSelected) return const SizedBox.shrink();

              return GestureDetector(
                onTap: _isEditing
                    ? () {
                        if (!isSelected && _categoriasSelecionadas.length >= _maxCategorias) {
                          AppToast.error(context, 'Escolha no máximo $_maxCategorias categorias.');
                          return;
                        }
                        setState(() {
                          if (isSelected) {
                            _categoriasSelecionadas.remove(cat.id);
                          } else {
                            _categoriasSelecionadas.add(cat.id);
                          }
                        });
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorsPalette.black : context.mapColors.cardSurface,
                    borderRadius: BorderRadius.circular(100.0),
                    // Não-selecionado: borda na mesma cor do fundo, pra
                    // manter o contorno "invisível" como no design original
                    // (não usar o token `border`, que criaria um contorno
                    // visível que não existia antes).
                    border: Border.all(
                      color: isSelected
                          ? ColorsPalette.black
                          : context.mapColors.cardSurface,
                    ),
                  ),
                  child: Text(
                    cat.nome,
                    // Não-selecionado sem override: legenda() já resolve pra secondaryText.
                    style: AppText.legenda(context).copyWith(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildAvaliacoesSection() {
    final avaliacao = _mediaAvaliacao;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Avaliações",
                  style: AppText.titulo(
                    context,
                  ).copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  "O que dizem sobre você",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: context.mapColors.secondaryText),
                ),
              ],
            ),
            if (avaliacao != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      avaliacao.toStringAsFixed(1),
                      style: AppText.subtitulo(context).copyWith(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        if (_isLoadingAvaliacoes)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: CircularProgressIndicator(
                color: ColorsPalette.redComponents,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_avaliacoes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.mapColors.cardSurface,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: context.mapColors.border),
            ),
            child: Text(
              'Nenhuma avaliação recebida ainda.',
              style: AppText.corpo(
                context,
              ).copyWith(color: context.mapColors.secondaryText),
            ),
          )
        else
          ..._avaliacoes.map((review) {
            final nome = review.consumidor?.nome ?? 'Usuário';
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.mapColors.cardSurface,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            // Um tom abaixo do cardSurface do card que
                            // envolve este avatar (superfície aninhada).
                            backgroundColor: context.mapColors.mainBackground,
                            child: Text(
                              nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.mapColors.primaryText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            nome,
                            style: AppText.corpo(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // Sem override de cor: legenda() já resolve pra secondaryText.
                      Text(
                        _formatDate(review.dataAvaliacao),
                        style: AppText.legenda(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.nota
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  if (review.comentario != null &&
                      review.comentario!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      review.comentario!,
                      style: AppText.corpo(
                        context,
                      ).copyWith(color: context.mapColors.secondaryText, height: 1.4),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inDays == 0) return 'Hoje';
      if (diff.inDays == 1) return 'Ontem';
      if (diff.inDays < 7) return 'Há ${diff.inDays} dias';
      if (diff.inDays < 30) return 'Há ${(diff.inDays / 7).floor()} semanas';
      if (diff.inDays < 365) return 'Há ${(diff.inDays / 30).floor()} meses';
      return 'Há ${(diff.inDays / 365).floor()} anos';
    } catch (_) {
      return '';
    }
  }
}
