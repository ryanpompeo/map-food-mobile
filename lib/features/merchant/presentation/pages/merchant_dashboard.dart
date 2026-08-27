import 'package:flutter/foundation.dart' show kIsWeb, setEquals;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/cep_service.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_elevation.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/theme/metric_colors.dart';
import 'package:map_food/core/ui/widgets/app_bottom_bar.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/profile_stat_card.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/avaliacoes/data/models/avaliacao_model.dart';
import 'package:map_food/features/avaliacoes/data/services/avaliacao_service.dart';
import 'package:map_food/features/merchant/presentation/widgets/store_reviews_section.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/category_picker.dart';
import 'package:map_food/features/store/presentation/widgets/store_photos_editor.dart';

/// Altura da barra de ação de edição, com o botão de 52 e o padding de 12
/// em cima e embaixo — usada para reservar rodapé no scroll enquanto ela
/// está na tela.
const double _alturaBarraDeAcao = 52.0 + (Spacing.md * 2);

/// Perfil público da loja, do lado de quem administra: consulta e edição no
/// mesmo lugar, alternadas por um botão.
///
/// A mudança estrutural desta versão é a separação entre **ler** e **editar**.
/// Antes, os dois modos eram a mesma pilha de `TextField`s — em consulta eles
/// apareciam apenas cinzas e somente-leitura, o que dava a uma tela de
/// conferência a aparência de um formulário pela metade, e obrigava a
/// desconfiar de cada campo ("isto está travado ou eu é que não consigo
/// digitar?"). Agora consultar é uma lista de informações, e editar é um
/// formulário de verdade, com barra de ação fixa.
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
  final _formKey = GlobalKey<FormState>();

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

  static const int _maxFotosGaleria = 10;
  final _storeService = StoreService();
  final _categoriaService = CategoriaService();
  final _avaliacaoService = AvaliacaoService();
  final _cepService = CepService();
  bool _buscandoCep = false;

  List<CategoriaModel> _categorias = [];
  bool _isLoadingCategorias = true;

  /// Mensagem de falha ao buscar as categorias — null quando deu certo.
  String? _erroCategorias;

  List<AvaliacaoModel> _avaliacoes = [];
  bool _isLoadingAvaliacoes = true;

  // Agregação de avaliação vinda do backend (Fase 4) — não é mais calculada
  // no cliente a partir de `_avaliacoes`.
  double? _mediaAvaliacao;

  /// Alimenta o `UnsavedChangesGuard` (gesto de voltar do Android) sem
  /// reconstruir a tela a cada tecla digitada.
  final ValueNotifier<bool> _temAlteracoes = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _inicializarDados();
    _carregarCategorias();
    _carregarAvaliacoes();
    _carregarMediaAvaliacao();
  }

  @override
  void didUpdateWidget(covariant MerchantDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Resincroniza com a versão mais recente vinda do pai (ex: PUT de
    // posição disparado pela ronda de GPS em MerchantWorkingPage, que fica
    // viva em segundo plano no mesmo IndexedStack). Não mexe nos
    // TextEditingController enquanto `_isEditing` for true, pra não apagar
    // uma digitação em andamento.
    if (widget.store.id == _store.id && !_isEditing) {
      setState(() => _store = widget.store);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onFormChanged);
      controller.dispose();
    }
    _temAlteracoes.dispose();
    super.dispose();
  }

  List<TextEditingController> get _controllers => [
        _nomeController,
        _descricaoController,
        _enderecoController,
        _cidadeController,
        _estadoController,
        _cepController,
      ];

  void _inicializarDados() {
    _store = widget.store;
    _nomeController = TextEditingController(text: widget.store.nome);
    _descricaoController = TextEditingController(text: widget.store.descricao ?? '');
    _enderecoController = TextEditingController(text: widget.store.endereco ?? '');
    _cidadeController = TextEditingController(text: widget.store.cidade ?? '');
    _estadoController = TextEditingController(text: widget.store.estado ?? '');
    _cepController = TextEditingController(text: widget.store.cep ?? '');
    _categoriasSelecionadas = List.from(widget.store.categoriaIds);
    for (final controller in _controllers) {
      controller.addListener(_onFormChanged);
    }
  }

  void _onFormChanged() {
    final dirty = _computeTemAlteracoes();
    if (_temAlteracoes.value != dirty) _temAlteracoes.value = dirty;
  }

  bool _computeTemAlteracoes() {
    if (!_isEditing) return false;
    return _nomeController.text.trim() != _store.nome ||
        _descricaoController.text.trim() != (_store.descricao ?? '') ||
        _enderecoController.text.trim() != (_store.endereco ?? '') ||
        _cidadeController.text.trim() != (_store.cidade ?? '') ||
        _estadoController.text.trim() != (_store.estado ?? '') ||
        _cepController.text.trim() != (_store.cep ?? '') ||
        _novaCapa != null ||
        _novasFotosGaleria.isNotEmpty ||
        !setEquals(_categoriasSelecionadas.toSet(), _store.categoriaIds.toSet());
  }

  Future<void> _carregarMediaAvaliacao() async {
    try {
      final resumo = await _storeService.getResumo(widget.store.id);
      if (mounted) setState(() => _mediaAvaliacao = resumo.avaliacao);
    } catch (_) {
      // Mantém null ("Novo") se a busca falhar.
    }
  }

  /// Mesmo cuidado do cadastro de loja: falha aqui não pode ser silenciosa.
  /// Sem categorias na tela, o comerciante que abre a edição vê a seção
  /// vazia e conclui que perdeu as categorias já salvas na loja.
  Future<void> _carregarCategorias() async {
    if (mounted) {
      setState(() {
        _isLoadingCategorias = true;
        _erroCategorias = null;
      });
    }
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) {
        setState(() {
          _categorias = categorias;
          _isLoadingCategorias = false;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _erroCategorias = e.message;
          _isLoadingCategorias = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _erroCategorias = 'Não foi possível carregar as categorias.';
          _isLoadingCategorias = false;
        });
      }
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

  Future<void> _removerCapaSalva() async {
    // `imagemUrl`, não o getter `capaUrl`: este último cai para a primeira
    // foto da galeria quando não há capa definida. Ali, "remover capa"
    // chamaria o endpoint de capa para uma foto que na verdade é da galeria
    // — a chamada volta sem efeito e a foto continua na tela.
    if (_store.imagemUrl == null) return;
    final confirmou = await confirmarRemocaoFoto(context);
    if (!confirmou || !mounted) return;

    setState(() => _isRemovendoCapa = true);
    try {
      final atualizada = await _storeService.removerImagemCapa(widget.store.id);
      if (mounted) setState(() => _store = atualizada);
      widget.onStoreUpdated?.call(atualizada);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível remover a foto. Tente novamente.');
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
      final atualizada = await _storeService.removerFotoGaleria(widget.store.id, url);
      if (mounted) setState(() => _store = atualizada);
      widget.onStoreUpdated?.call(atualizada);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível remover a foto. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _removendoGaleriaUrl = null);
    }
  }

  /// Salva direto, sem diálogo de "deseja confirmar?".
  ///
  /// A confirmação anterior pedia para confirmar duas vezes uma ação que já
  /// era explícita e reversível (dá para editar de novo em dois toques) —
  /// enquanto o **descarte**, esse sim destrutivo, saía sem perguntar nada.
  /// A fricção foi movida para o lado certo: ver `_cancelarEdicao`.
  Future<void> _salvar() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? true)) return;

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
        descricao: _textoOuNulo(_descricaoController),
        statusLoja: widget.store.statusLoja,
        categoriaIds: List.from(_categoriasSelecionadas),
        endereco: _textoOuNulo(_enderecoController),
        cidade: _textoOuNulo(_cidadeController),
        estado: _textoOuNulo(_estadoController)?.toUpperCase(),
        cep: _textoOuNulo(_cepController),
        latitude: latitude,
        longitude: longitude,
      );

      var lojaAtualizada = await _storeService.update(widget.store.id, request);

      if (_novaCapa != null) {
        lojaAtualizada = await _storeService.uploadImagemCapa(widget.store.id, _novaCapa!);
      }
      if (_novasFotosGaleria.isNotEmpty) {
        lojaAtualizada = await _storeService.uploadGaleria(widget.store.id, _novasFotosGaleria);
      }

      if (mounted) {
        setState(() {
          _isEditing = false;
          _store = lojaAtualizada;
          _novaCapa = null;
          _novasFotosGaleria.clear();
        });
        _temAlteracoes.value = false;
        widget.onStoreUpdated?.call(lojaAtualizada);
        AppToast.success(context, 'Informações atualizadas com sucesso!');
      }
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Erro ao salvar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  static String? _textoOuNulo(TextEditingController controller) {
    final texto = controller.text.trim();
    return texto.isEmpty ? null : texto;
  }

  Future<void> _cancelarEdicao() async {
    // Descartar é o que não tem volta — é aqui que a confirmação faz sentido.
    if (_temAlteracoes.value) {
      final confirmou = await confirmarSaidaSemSalvar(context);
      if (!confirmou || !mounted) return;
    }
    setState(() {
      _isEditing = false;
      _nomeController.text = _store.nome;
      _descricaoController.text = _store.descricao ?? '';
      _enderecoController.text = _store.endereco ?? '';
      _cidadeController.text = _store.cidade ?? '';
      _estadoController.text = _store.estado ?? '';
      _cepController.text = _store.cep ?? '';
      _categoriasSelecionadas = List.from(_store.categoriaIds);
      _novaCapa = null;
      _novasFotosGaleria.clear();
    });
    _temAlteracoes.value = false;
  }

  void _entrarEmEdicao() => setState(() => _isEditing = true);

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    // Com o teclado aberto a bottom bar do container pai sai de cena, então a
    // barra de ação desce até a borda do teclado em vez de flutuar 92px acima
    // de nada.
    final tecladoAberto = MediaQuery.viewInsetsOf(context).bottom > 0;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _temAlteracoes,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + Spacing.base,
                  bottom: AppBottomBar.reservedSpace +
                      (_isEditing ? _alturaBarraDeAcao : 0.0) +
                      Spacing.lg,
                ),
                children: [
                  if (widget.storeSwitcher != null) ...[
                    widget.storeSwitcher!,
                    const SizedBox(height: Spacing.lg),
                  ],
                  _bloco(child: _buildCabecalho()),
                  const SizedBox(height: Spacing.lg),
                  ProfileStatsRow(horizontalPadding: Spacing.lg, stats: _stats()),
                  const SizedBox(height: Spacing.xl),

                  _bloco(child: _buildFotos()),
                  const SizedBox(height: Spacing.xl),

                  _bloco(child: _buildDadosPrincipais()),
                  const SizedBox(height: Spacing.xl),

                  _bloco(child: _buildEndereco()),
                  const SizedBox(height: Spacing.xl),

                  _bloco(child: _buildCategorias()),
                  const SizedBox(height: Spacing.xl),

                  Divider(color: colors.divider, height: 1),
                  const SizedBox(height: Spacing.xl),

                  _bloco(
                    child: StoreReviewsSection(
                      avaliacoes: _avaliacoes,
                      carregando: _isLoadingAvaliacoes,
                      media: _mediaAvaliacao,
                    ),
                  ),
                ],
              ),
            ),

            if (_isEditing)
              Positioned(
                left: 0,
                right: 0,
                bottom: tecladoAberto ? 0 : AppBottomBar.reservedSpace,
                child: _BarraDeAcao(
                  salvando: _isSaving,
                  onCancelar: _isSaving ? null : _cancelarEdicao,
                  onSalvar: _salvar,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bloco({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: child,
      );

  Widget _buildCabecalho() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Perfil da loja', style: AppText.h1(context)),
              const SizedBox(height: 2),
              Text(
                _isEditing
                    ? 'As mudanças aparecem para os clientes assim que você salvar.'
                    : 'É assim que os clientes veem a sua loja.',
                style: AppText.secondary(context).copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        if (!_isEditing) ...[
          const SizedBox(width: Spacing.md),
          AppButton(
            label: 'Editar',
            icon: AppIcons.pencilSimple,
            onPressed: _entrarEmEdicao,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.sm,
            expand: false,
          ),
        ],
      ],
    );
  }

  /// Três números que o comerciante consegue conferir sem abrir mais nada —
  /// todos já disponíveis localmente, sem chamada de API extra.
  List<ProfileStat> _stats() {
    final dias = _store.dataCadastro != null
        ? DateTime.now().difference(DateTime.parse(_store.dataCadastro!)).inDays
        : 0;
    return [
      ProfileStat(label: 'Dias como parceiro', value: '$dias', color: AppMetricColors.diasNoApp),
      ProfileStat(label: 'Avaliações', value: '${_avaliacoes.length}', color: AppMetricColors.avaliacoes),
      ProfileStat(
        label: 'Categorias',
        value: '${_categoriasSelecionadas.length}/$_maxCategorias',
        color: AppMetricColors.categorias,
      ),
    ];
  }

  Widget _buildFotos() {
    return StorePhotosEditor(
      editando: _isEditing,
      // A capa de verdade, não o getter `capaUrl` (que cai para a primeira
      // foto da galeria): no editor, a mesma imagem apareceria ao mesmo tempo
      // como capa e como item da galeria, sugerindo uma capa que não existe.
      capaUrl: _store.imagemUrl,
      novaCapa: _novaCapa,
      removendoCapa: _isRemovendoCapa,
      galeriaSalva: _store.galeria,
      novasFotos: _novasFotosGaleria,
      removendoGaleriaUrl: _removendoGaleriaUrl,
      maxFotos: _maxFotosGaleria,
      onEscolherCapa: () async {
        final file = await pickImageFromSheet(context);
        if (file == null) return;
        setState(() => _novaCapa = file);
        _onFormChanged();
      },
      onRemoverCapaSalva: _removerCapaSalva,
      onDescartarNovaCapa: () {
        setState(() => _novaCapa = null);
        _onFormChanged();
      },
      onAdicionarFoto: () async {
        final file = await pickImageFromSheet(context);
        if (file == null) return;
        setState(() => _novasFotosGaleria.add(file));
        _onFormChanged();
      },
      onRemoverFotoSalva: _removerFotoGaleriaSalva,
      onDescartarNovaFoto: (foto) {
        setState(() => _novasFotosGaleria.remove(foto));
        _onFormChanged();
      },
    );
  }

  Widget _buildDadosPrincipais() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dados da loja', style: AppText.h2(context)),
        const SizedBox(height: Spacing.base),
        if (_isEditing) ...[
          AppFormField(
            controller: _nomeController,
            label: 'Nome do comércio',
            hint: 'Ex: Carrinho do João',
            icon: AppIcons.storefront,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
          ),
          const SizedBox(height: Spacing.base),
          AppFormField(
            controller: _descricaoController,
            label: 'Descrição',
            hint: 'Ex: Lanches e porções preparados na hora',
            icon: AppIcons.textAlignLeft,
            maxLines: 3,
          ),
        ] else ...[
          _LinhaInfo(icone: AppIcons.storefront, rotulo: 'Nome', valor: _store.nome),
          _LinhaInfo(
            icone: AppIcons.textAlignLeft,
            rotulo: 'Descrição',
            valor: _store.descricao,
          ),
        ],
      ],
    );
  }

  Widget _buildEndereco() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Endereço', style: AppText.h2(context)),
        const SizedBox(height: 2),
        Text(
          'Opcional. Sua loja entra no mapa pela localização em tempo real ao '
          'ficar "Aberta" — o endereço serve só como área de referência.',
          style: AppText.secondary(context).copyWith(height: 1.4),
        ),
        const SizedBox(height: Spacing.base),
        if (_isEditing) ...[
          AppFormField(
            controller: _cepController,
            label: 'CEP',
            hint: '00000-000',
            icon: AppIcons.hash,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: _onCepChanged,
            suffixIcon: _buscandoCep
                ? const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: SizedBox(
                      width: 16.0,
                      height: 16.0,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: Spacing.base),
          AppFormField(
            controller: _enderecoController,
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
                  controller: _cidadeController,
                  label: 'Cidade',
                  hint: 'Ex: Campinas',
                  icon: AppIcons.buildingOffice,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: AppFormField(
                  controller: _estadoController,
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
        ] else
          _LinhaInfo(
            icone: AppIcons.mapPinLine,
            rotulo: 'Endereço',
            valor: _enderecoFormatado,
          ),
      ],
    );
  }

  String? get _enderecoFormatado {
    final partes = [
      _store.endereco,
      [_store.cidade, _store.estado].where((p) => p?.isNotEmpty == true).join(' - '),
      _store.cep,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return partes.isEmpty ? null : partes.join('\n');
  }

  Widget _buildCategorias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categorias', style: AppText.h2(context)),
        const SizedBox(height: 2),
        Text(
          _isEditing
              ? 'Escolha até $_maxCategorias — é por elas que o cliente filtra no mapa.'
              : 'É por elas que o cliente encontra você no mapa.',
          style: AppText.secondary(context).copyWith(height: 1.4),
        ),
        const SizedBox(height: Spacing.base),
        CategoryPicker(
          categorias: _categorias,
          selecionadas: _categoriasSelecionadas,
          carregando: _isLoadingCategorias,
          erro: _erroCategorias,
          onRetry: _carregarCategorias,
          maxSelecao: _maxCategorias,
          onLimiteExcedido: () =>
              AppToast.error(context, 'Escolha no máximo $_maxCategorias categorias.'),
          onToggle: _isEditing
              ? (cat) {
                  setState(() {
                    if (_categoriasSelecionadas.contains(cat.id)) {
                      _categoriasSelecionadas.remove(cat.id);
                    } else {
                      _categoriasSelecionadas.add(cat.id);
                    }
                  });
                  _onFormChanged();
                }
              : null,
        ),
      ],
    );
  }
}

/// Linha de consulta: rótulo pequeno em cima, valor com contraste embaixo.
///
/// Valor ausente vira "Não informado" em tom terciário em vez de espaço em
/// branco — vazio silencioso lê como falha de carregamento.
class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String? valor;

  const _LinhaInfo({required this.icone, required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;
    final vazio = valor == null || valor!.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icone, size: AppIconSize.md, color: colors.textTertiary),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: AppText.caption(context)),
                const SizedBox(height: 2),
                Text(
                  vazio ? 'Não informado' : valor!,
                  style: AppText.body(context).copyWith(
                    height: 1.4,
                    color: vazio ? colors.textTertiary : colors.textPrimary,
                    fontWeight: vazio ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra fixa de "Cancelar / Salvar" durante a edição.
///
/// Substitui o `FloatingActionButton.extended` com `Padding(bottom: 150)` que
/// existia aqui: além do número mágico, um FAB centralizado tapava conteúdo
/// da própria lista que se estava editando, e não tinha para onde colocar o
/// "Cancelar" — que vivia como um link de texto lá no topo da tela, longe do
/// polegar e longe da ação que ele desfaz.
class _BarraDeAcao extends StatelessWidget {
  final bool salvando;
  final VoidCallback? onCancelar;
  final VoidCallback onSalvar;

  const _BarraDeAcao({
    required this.salvando,
    required this.onCancelar,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: AppElevation.floating,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancelar',
                  onPressed: onCancelar,
                  variant: AppButtonVariant.secondary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'Salvar',
                  icon: AppIcons.floppyDisk,
                  onPressed: onSalvar,
                  loading: salvando,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
