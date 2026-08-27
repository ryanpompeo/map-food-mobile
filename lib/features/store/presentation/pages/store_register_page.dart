import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/network/cep_service.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/validators/form_validator.dart';
import 'package:map_food/core/ui/widgets/app_button.dart';
import 'package:map_food/core/ui/widgets/app_form_field.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/category_picker.dart';
import 'package:map_food/features/store/presentation/widgets/store_photos_editor.dart';

/// Cadastro da loja — a primeira tela obrigatória de quem entra como
/// comerciante (o app redireciona para cá enquanto não houver loja).
///
/// Passou a compartilhar `StorePhotosEditor` e `CategoryPicker` com a edição
/// de loja: as duas telas mantinham cópias divergentes dos mesmos blocos, e a
/// primeira impressão do comerciante era justamente a versão que ficava para
/// trás a cada ajuste feito só do outro lado.
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

  /// Erro de submit — estado da tela, não notificação: fica visível junto do
  /// botão até ser corrigido, em vez de sumir sozinho como um toast.
  String? _errorMessage;
  bool _isLoading = false;

  // ValueNotifier (não bool simples) de propósito: o UnsavedChangesGuard
  // isola o rebuild no próprio ValueListenableBuilder interno dele, então
  // atualizar isso não reconstrói mais a página inteira a cada tecla.
  final ValueNotifier<bool> _hasUnsavedChanges = ValueNotifier(false);

  final _storeService = StoreService();
  final _categoriaService = CategoriaService();
  final _cepService = CepService();
  bool _buscandoCep = false;

  XFile? _fotoDestaque;

  final List<XFile> _fotosGaleria = [];
  static const int _maxFotos = 10;

  static const int _maxCategorias = 3;
  final List<int> _categoriasSelecionadas = [];

  List<CategoriaModel> _categorias = [];
  bool _isLoadingCategorias = true;

  /// Mensagem de falha ao buscar as categorias — null quando deu certo.
  String? _erroCategorias;

  List<TextEditingController> get _controllers => [
        _nomeController,
        _descricaoController,
        _enderecoController,
        _cidadeController,
        _estadoController,
        _cepController,
      ];

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    // Atualiza o ValueNotifier do UnsavedChangesGuard a cada tecla digitada
    // — sem reconstruir a página inteira, só o PopScope interno do guard.
    for (final controller in _controllers) {
      controller.addListener(_onFormChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.removeListener(_onFormChanged);
      controller.dispose();
    }
    _hasUnsavedChanges.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    final dirty = _computeHasUnsavedChanges();
    if (_hasUnsavedChanges.value != dirty) _hasUnsavedChanges.value = dirty;
  }

  bool _computeHasUnsavedChanges() =>
      _controllers.any((c) => c.text.isNotEmpty) ||
      _fotoDestaque != null ||
      _fotosGaleria.isNotEmpty ||
      _categoriasSelecionadas.isNotEmpty;

  /// Carrega as categorias disponíveis.
  ///
  /// A falha aqui **não pode ser silenciosa**: escolher ao menos uma
  /// categoria é obrigatório para concluir o cadastro. Antes, quando a
  /// chamada falhava (API fora do ar, por exemplo), o `catch` vazio só
  /// desligava o loading — a seção ficava com título, subtítulo e nada
  /// embaixo, o botão continuava habilitado, e ao tocar nele a pessoa recebia
  /// "Selecione pelo menos uma categoria" sem ter o que selecionar.
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

  /// Converte o endereço digitado (opcional — muitos comércios daqui são
  /// ambulantes, sem endereço fixo) em lat/lng pra dar um ponto inicial no
  /// mapa. A posição de verdade vem do GPS ao vivo quando a loja fica
  /// "Aberta"/Em Ronda (ver `merchant_working_page.dart`); isso aqui é só um
  /// fallback pra quem quer indicar uma área de referência já no cadastro.
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

  Future<void> _concluirCadastro() async {
    if (_isLoading) return;

    // O banner some assim que a pessoa toca em concluir de novo: manter o
    // erro anterior na tela durante a nova tentativa faz parecer que ela
    // falhou de novo antes mesmo de a chamada sair.
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (_fotoDestaque == null) {
      setState(() => _errorMessage = 'Adicione uma foto de destaque para o seu comércio.');
      return;
    }

    if (_categoriasSelecionadas.isEmpty) {
      setState(() => _errorMessage = 'Selecione pelo menos uma categoria.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final (latitude, longitude) = await _geocodificarEndereco();

      // Sem localização, a loja fica invisível no mapa mesmo com status
      // ATIVA — melhor já nascer INATIVA e deixar claro que falta ativar
      // via "Em Ronda" (que captura a posição por GPS) do que criar uma
      // loja "ativa" fantasma que ninguém encontra.
      final temLocalizacao = latitude != null && longitude != null;

      final request = StoreCreateRequest(
        nome: _nomeController.text.trim(),
        descricao: _textoOuNulo(_descricaoController),
        statusLoja: temLocalizacao ? 'ATIVA' : 'INATIVA',
        categoriaIds: List<int>.from(_categoriasSelecionadas),
        endereco: _textoOuNulo(_enderecoController),
        cidade: _textoOuNulo(_cidadeController),
        estado: _textoOuNulo(_estadoController)?.toUpperCase(),
        cep: _textoOuNulo(_cepController),
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

      if (!temLocalizacao && mounted) {
        AppToast.success(
          context,
          'Loja cadastrada como Fechada — abra "Em Ronda" pra ativar com sua localização.',
        );
      }

      if (!mounted) return;

      // A loja foi criada: a partir daqui não há mais rascunho a proteger, e
      // sem zerar isto o guard interceptaria a própria navegação de sucesso.
      _hasUnsavedChanges.value = false;

      // MerchantHomePage carrega os dados reais do banco automaticamente.
      unawaited(Navigator.pushAndRemoveUntil(
        context,
        appPageRoute(builder: (_) => const MerchantHomePage()),
        (route) => false,
      ));
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao cadastrar loja. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static String? _textoOuNulo(TextEditingController controller) {
    final texto = controller.text.trim();
    return texto.isEmpty ? null : texto;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          // Sem seta, o título alinha com a margem do conteúdo; com seta,
          // vale o espaçamento padrão do Material a partir dela.
          titleSpacing: Navigator.canPop(context) ? null : Spacing.lg,
          // Sem `automaticallyImplyLeading: false`: o AppBar já só desenha a
          // seta quando há para onde voltar. Fixar `leading: Container()`,
          // como estava, tirava a saída de quem chega aqui pelo chip "Nova
          // loja" — no cadastro obrigatório (entrou sem loja) a pilha não
          // tem rota anterior e a seta continua ausente de qualquer forma.
          title: Text('Cadastrar loja', style: AppText.h2(context)),
        ),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.xxl,
              ),
              children: [
                Text(
                  'Só o essencial para você aparecer no mapa. Dá para ajustar '
                  'tudo depois, no perfil da loja.',
                  style: AppText.secondary(context).copyWith(height: 1.45),
                ),
                const SizedBox(height: Spacing.xl),

                StorePhotosEditor(
                  editando: true,
                  capaObrigatoria: true,
                  capaUrl: null,
                  novaCapa: _fotoDestaque,
                  galeriaSalva: const [],
                  novasFotos: _fotosGaleria,
                  maxFotos: _maxFotos,
                  onEscolherCapa: () async {
                    final file = await pickImageFromSheet(context);
                    if (file == null) return;
                    setState(() => _fotoDestaque = file);
                    _onFormChanged();
                  },
                  // Sem foto salva no servidor nesta tela: os dois caminhos de
                  // remoção caem no mesmo descarte local.
                  onRemoverCapaSalva: () {},
                  onDescartarNovaCapa: () {
                    setState(() => _fotoDestaque = null);
                    _onFormChanged();
                  },
                  onAdicionarFoto: () async {
                    final file = await pickImageFromSheet(context);
                    if (file == null) return;
                    setState(() => _fotosGaleria.add(file));
                    _onFormChanged();
                  },
                  onRemoverFotoSalva: (_) {},
                  onDescartarNovaFoto: (foto) {
                    setState(() => _fotosGaleria.remove(foto));
                    _onFormChanged();
                  },
                ),
                const SizedBox(height: Spacing.xxl),

                _TituloSecao(
                  titulo: 'Dados principais',
                  apoio: 'É o que aparece no card da sua loja para o cliente.',
                ),
                const SizedBox(height: Spacing.base),
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
                  label: 'Breve descrição',
                  hint: 'Ex: Lanches e porções preparados na hora',
                  icon: AppIcons.textAlignLeft,
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                ),
                const SizedBox(height: Spacing.xxl),

                _TituloSecao(
                  titulo: 'Endereço',
                  selo: 'Opcional',
                  apoio: 'Sua loja entra no mapa pela localização em tempo real ao '
                      'ficar "Aberta" — preencha só se quiser indicar uma área de '
                      'referência.',
                ),
                const SizedBox(height: Spacing.base),
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
                  validator: (v) => v == null || v.isEmpty ? null : FormValidator.cep(v),
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
                            v == null || v.trim().isEmpty || v.trim().length == 2
                                ? null
                                : 'Inválido',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xxl),

                _TituloSecao(
                  titulo: 'Categorias',
                  apoio: 'Escolha até $_maxCategorias — é por elas que o cliente '
                      'filtra no mapa.',
                ),
                const SizedBox(height: Spacing.base),
                CategoryPicker(
                  categorias: _categorias,
                  selecionadas: _categoriasSelecionadas,
                  carregando: _isLoadingCategorias,
                  erro: _erroCategorias,
                  onRetry: _carregarCategorias,
                  maxSelecao: _maxCategorias,
                  onLimiteExcedido: () => AppToast.error(
                    context,
                    'Escolha no máximo $_maxCategorias categorias.',
                  ),
                  onToggle: (cat) {
                    setState(() {
                      if (_categoriasSelecionadas.contains(cat.id)) {
                        _categoriasSelecionadas.remove(cat.id);
                      } else {
                        _categoriasSelecionadas.add(cat.id);
                      }
                    });
                    _onFormChanged();
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: Spacing.xl),
                  FormErrorBanner(message: _errorMessage),
                ],

                const SizedBox(height: Spacing.xxl),
                AppButton(
                  label: 'Concluir cadastro',
                  onPressed: _concluirCadastro,
                  loading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  final String titulo;
  final String apoio;
  final String? selo;

  const _TituloSecao({required this.titulo, required this.apoio, this.selo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(titulo, style: AppText.h2(context)),
            if (selo != null) ...[
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: context.mapColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(
                  selo!,
                  style: AppText.overline(context).copyWith(fontSize: 10),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(apoio, style: AppText.secondary(context).copyWith(height: 1.45)),
      ],
    );
  }
}
