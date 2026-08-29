import 'package:flutter/foundation.dart' show kIsWeb, setEquals;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/core/ui/widgets/wizard_footer.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';
import 'package:map_food/features/store/presentation/widgets/category_picker.dart';
import 'package:map_food/features/store/presentation/widgets/store_form_fields.dart';
import 'package:map_food/features/store/presentation/widgets/store_photos_editor.dart';

/// Edição do perfil público da loja — foto, dados, endereço e categorias.
///
/// É uma página empurrada, e não um modo da tela de gestão. Antes, consultar e
/// editar dividiam a mesma tela: para **ver** o nome da loja, o painel montava
/// um formulário inteiro e uma barra flutuante de salvar. Isso é o oposto do
/// que um painel precisa ser — ele responde perguntas rápidas, e formulário é
/// uma tarefa com começo, meio e fim.
///
/// Devolve a [StoreDto] atualizada pelo `Navigator.pop` quando algo é salvo, ou
/// `null` quando a pessoa sai sem salvar.
class StoreEditPage extends StatefulWidget {
  final StoreDto store;

  const StoreEditPage({super.key, required this.store});

  @override
  State<StoreEditPage> createState() => _StoreEditPageState();
}

class _StoreEditPageState extends State<StoreEditPage> {
  final _formKey = GlobalKey<FormState>();

  late StoreDto _store;

  late final _nome = TextEditingController(text: widget.store.nome);
  late final _descricao = TextEditingController(text: widget.store.descricao ?? '');
  late final _endereco = TextEditingController(text: widget.store.endereco ?? '');
  late final _cidade = TextEditingController(text: widget.store.cidade ?? '');
  late final _estado = TextEditingController(text: widget.store.estado ?? '');
  late final _cep = TextEditingController(text: widget.store.cep ?? '');

  late final List<TextEditingController> _campos = [
    _nome,
    _descricao,
    _endereco,
    _cidade,
    _estado,
    _cep,
  ];

  late List<int> _categoriasSelecionadas;

  /// Fotos escolhidas nesta sessão, ainda não enviadas. As já salvas vivem em
  /// `_store.imagemUrl`/`_store.galeria` e são removidas direto no servidor.
  XFile? _novaCapa;
  final List<XFile> _novasFotos = [];

  bool _salvando = false;
  bool _removendoCapa = false;
  String? _removendoGaleriaUrl;
  String? _erro;

  static const int _maxFotos = 10;
  static const int _maxCategorias = 3;

  final _storeService = StoreService();
  final _categoriaService = CategoriaService();

  List<CategoriaModel> _categorias = [];
  bool _carregandoCategorias = true;
  String? _erroCategorias;

  /// Alimenta o `UnsavedChangesGuard` sem reconstruir a tela a cada tecla.
  final ValueNotifier<bool> _temAlteracoes = ValueNotifier(false);

  /// `true` assim que algo é persistido — o painel precisa saber que a loja
  /// mudou mesmo se a pessoa sair pelo gesto de voltar depois de uma remoção
  /// de foto (que grava na hora, sem passar pelo "Salvar").
  bool _houveMudanca = false;

  @override
  void initState() {
    super.initState();
    _store = widget.store;
    _categoriasSelecionadas = List.from(widget.store.categoriaIds);
    for (final campo in _campos) {
      campo.addListener(_onFormChanged);
    }
    _carregarCategorias();
  }

  @override
  void dispose() {
    for (final campo in _campos) {
      campo.removeListener(_onFormChanged);
      campo.dispose();
    }
    _temAlteracoes.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    final dirty = _nome.text.trim() != _store.nome ||
        _descricao.text.trim() != (_store.descricao ?? '') ||
        _endereco.text.trim() != (_store.endereco ?? '') ||
        _cidade.text.trim() != (_store.cidade ?? '') ||
        _estado.text.trim() != (_store.estado ?? '') ||
        _cep.text.trim() != (_store.cep ?? '') ||
        _novaCapa != null ||
        _novasFotos.isNotEmpty ||
        !setEquals(_categoriasSelecionadas.toSet(), _store.categoriaIds.toSet());
    if (_temAlteracoes.value != dirty) _temAlteracoes.value = dirty;
  }

  /// Falha aqui não pode ser silenciosa: sem categorias na tela, quem abre a
  /// edição vê a seção vazia e conclui que perdeu as que já estavam salvas.
  Future<void> _carregarCategorias() async {
    setState(() {
      _carregandoCategorias = true;
      _erroCategorias = null;
    });
    try {
      final categorias = await _categoriaService.getAll();
      if (mounted) setState(() => _categorias = categorias);
    } on AppException catch (e) {
      if (mounted) setState(() => _erroCategorias = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _erroCategorias = 'Não foi possível carregar as categorias.');
      }
    } finally {
      if (mounted) setState(() => _carregandoCategorias = false);
    }
  }

  Future<void> _removerCapaSalva() async {
    // `imagemUrl`, não o getter `capaUrl`: este último cai para a primeira foto
    // da galeria quando não há capa definida, e ali "remover capa" chamaria o
    // endpoint de capa para uma foto que na verdade é da galeria — a chamada
    // volta sem efeito e a foto continua na tela.
    if (_store.imagemUrl == null) return;
    final confirmou = await confirmarRemocaoFoto(context);
    if (!confirmou || !mounted) return;

    setState(() => _removendoCapa = true);
    try {
      final atualizada = await _storeService.removerImagemCapa(_store.id);
      if (mounted) setState(() => _store = atualizada);
      _houveMudanca = true;
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível remover a foto. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _removendoCapa = false);
    }
  }

  Future<void> _removerFotoGaleriaSalva(String url) async {
    final confirmou = await confirmarRemocaoFoto(context);
    if (!confirmou || !mounted) return;

    setState(() => _removendoGaleriaUrl = url);
    try {
      final atualizada = await _storeService.removerFotoGaleria(_store.id, url);
      if (mounted) setState(() => _store = atualizada);
      _houveMudanca = true;
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível remover a foto. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _removendoGaleriaUrl = null);
    }
  }

  /// Converte o endereço digitado em lat/lng quando ele muda — ponto de
  /// referência inicial. A posição de verdade vem do GPS da ronda.
  Future<(double?, double?)> _geocodificar() async {
    // O pacote geocoding não tem implementação web.
    if (kIsWeb) return (null, null);
    if (_endereco.text.trim().isEmpty && _cidade.text.trim().isEmpty) {
      return (null, null);
    }
    try {
      final query = '${_endereco.text.trim()}, '
          '${_cidade.text.trim()} - ${_estado.text.trim()}, Brasil';
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isEmpty) return (null, null);
      return (locations.first.latitude, locations.first.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  /// Salva direto, sem diálogo de "deseja confirmar?".
  ///
  /// Confirmar aqui pediria duas confirmações para uma ação explícita e
  /// reversível, enquanto o **descarte** — esse sim destrutivo — sairia sem
  /// perguntar nada. A fricção fica do lado certo: ver `_cancelar`.
  Future<void> _salvar() async {
    if (_salvando) return;
    FocusScope.of(context).unfocus();
    setState(() => _erro = null);

    if (!(_formKey.currentState?.validate() ?? true)) return;
    if (_categoriasSelecionadas.isEmpty) {
      setState(() => _erro = 'Selecione pelo menos uma categoria.');
      return;
    }

    setState(() => _salvando = true);
    try {
      final enderecoMudou = _endereco.text.trim() != (_store.endereco ?? '') ||
          _cidade.text.trim() != (_store.cidade ?? '') ||
          _estado.text.trim() != (_store.estado ?? '');

      double? latitude;
      double? longitude;
      if (enderecoMudou && _endereco.text.trim().isNotEmpty) {
        (latitude, longitude) = await _geocodificar();
      }

      var atualizada = await _storeService.update(
        _store.id,
        StoreCreateRequest(
          nome: _nome.text.trim(),
          descricao: _textoOuNulo(_descricao),
          statusLoja: _store.statusLoja,
          categoriaIds: List.from(_categoriasSelecionadas),
          endereco: _textoOuNulo(_endereco),
          cidade: _textoOuNulo(_cidade),
          estado: _textoOuNulo(_estado)?.toUpperCase(),
          cep: _textoOuNulo(_cep),
          latitude: latitude,
          longitude: longitude,
        ),
      );

      if (_novaCapa != null) {
        atualizada = await _storeService.uploadImagemCapa(_store.id, _novaCapa!);
      }
      if (_novasFotos.isNotEmpty) {
        atualizada = await _storeService.uploadGaleria(_store.id, _novasFotos);
      }

      _temAlteracoes.value = false;
      if (!mounted) return;
      AppToast.success(context, 'Informações atualizadas com sucesso!');
      Navigator.pop(context, atualizada);
    } catch (_) {
      if (mounted) setState(() => _erro = 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  /// Descartar é o que não tem volta — é aqui que a confirmação faz sentido.
  Future<void> _cancelar() async {
    if (_temAlteracoes.value) {
      final confirmou = await confirmarSaidaSemSalvar(context);
      if (!confirmou || !mounted) return;
    }
    Navigator.pop(context, _houveMudanca ? _store : null);
  }

  static String? _textoOuNulo(TextEditingController controller) {
    final texto = controller.text.trim();
    return texto.isEmpty ? null : texto;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return UnsavedChangesGuard(
      hasUnsavedChanges: _temAlteracoes,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: _cancelar,
            icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
          ),
          title: Text(
            'Editar loja',
            style: AppText.subtitulo(context).copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.base,
              Spacing.lg,
              Spacing.xxl,
            ),
            children: [
              StorePhotosEditor(
                editando: true,
                // A capa de verdade, não o getter `capaUrl` (que cai para a
                // primeira foto da galeria): no editor, a mesma imagem
                // apareceria ao mesmo tempo como capa e como item da galeria,
                // sugerindo uma capa que não existe.
                capaUrl: _store.imagemUrl,
                novaCapa: _novaCapa,
                removendoCapa: _removendoCapa,
                galeriaSalva: _store.galeria,
                novasFotos: _novasFotos,
                removendoGaleriaUrl: _removendoGaleriaUrl,
                maxFotos: _maxFotos,
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
                  setState(() => _novasFotos.add(file));
                  _onFormChanged();
                },
                onRemoverFotoSalva: _removerFotoGaleriaSalva,
                onDescartarNovaFoto: (foto) {
                  setState(() => _novasFotos.remove(foto));
                  _onFormChanged();
                },
              ),
              const SizedBox(height: Spacing.xxl),

              Text('Dados da loja', style: AppText.h2(context)),
              const SizedBox(height: Spacing.base),
              StoreIdentityFields(nome: _nome, descricao: _descricao),
              const SizedBox(height: Spacing.xxl),

              Text('Endereço', style: AppText.h2(context)),
              const SizedBox(height: 2),
              Text(
                'Opcional. Sua loja entra no mapa pela localização em tempo real ao '
                'ficar "Aberta" — o endereço serve só como área de referência.',
                style: AppText.secondary(context).copyWith(height: 1.4),
              ),
              const SizedBox(height: Spacing.base),
              StoreAddressFields(
                cep: _cep,
                endereco: _endereco,
                cidade: _cidade,
                estado: _estado,
                onAutofill: _onFormChanged,
              ),
              const SizedBox(height: Spacing.xxl),

              Text('Categorias', style: AppText.h2(context)),
              const SizedBox(height: 2),
              Text(
                'Escolha até $_maxCategorias — é por elas que o cliente filtra no mapa.',
                style: AppText.secondary(context).copyWith(height: 1.4),
              ),
              const SizedBox(height: Spacing.base),
              CategoryPicker(
                categorias: _categorias,
                selecionadas: _categoriasSelecionadas,
                carregando: _carregandoCategorias,
                erro: _erroCategorias,
                onRetry: _carregarCategorias,
                maxSelecao: _maxCategorias,
                onLimiteExcedido: () =>
                    AppToast.error(context, 'Escolha no máximo $_maxCategorias categorias.'),
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

              if (_erro != null) ...[
                const SizedBox(height: Spacing.xl),
                FormErrorBanner(message: _erro),
              ],
            ],
          ),
        ),
        bottomNavigationBar: WizardFooter(
          labelPrimario: 'Salvar',
          iconePrimario: AppIcons.floppyDisk,
          onPrimario: _salvar,
          carregando: _salvando,
          onVoltar: _cancelar,
          labelSecundario: 'Cancelar',
        ),
      ),
    );
  }
}
