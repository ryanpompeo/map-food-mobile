import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TextEditingController;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:image_picker/image_picker.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/features/store/data/models/categoria_model.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/categoria_service.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

enum StoreRegisterStep {
  identidade('Sua loja'),
  localizacao('Onde você fica'),
  exposicao('Como você aparece');

  final String rotulo;

  const StoreRegisterStep(this.rotulo);
}

class StoreRegisterController extends ChangeNotifier {
  StoreRegisterController({
    StoreService? storeService,
    CategoriaService? categoriaService,
  })  : _storeService = storeService ?? StoreService(),
        _categoriaService = categoriaService ?? CategoriaService() {
    for (final controller in campos) {
      controller.addListener(_recalcularRascunho);
    }
  }

  final StoreService _storeService;
  final CategoriaService _categoriaService;

  static const int maxFotos = 10;
  static const int maxCategorias = 3;

  final nome = TextEditingController();
  final descricao = TextEditingController();
  final endereco = TextEditingController();
  final cidade = TextEditingController();
  final estado = TextEditingController();
  final cep = TextEditingController();

  late final List<TextEditingController> campos = [
    nome,
    descricao,
    endereco,
    cidade,
    estado,
    cep,
  ];

  StoreRegisterStep _etapa = StoreRegisterStep.identidade;
  StoreRegisterStep get etapa => _etapa;

  int get indiceEtapa => StoreRegisterStep.values.indexOf(_etapa);
  int get totalEtapas => StoreRegisterStep.values.length;

  bool get naPrimeiraEtapa => indiceEtapa == 0;
  bool get naUltimaEtapa => indiceEtapa == totalEtapas - 1;

  void irPara(StoreRegisterStep etapa) {
    if (_etapa == etapa) return;
    _etapa = etapa;
    notifyListeners();
  }

  void avancar() {
    if (naUltimaEtapa) return;
    irPara(StoreRegisterStep.values[indiceEtapa + 1]);
  }

  void voltar() {
    if (naPrimeiraEtapa) return;
    irPara(StoreRegisterStep.values[indiceEtapa - 1]);
  }

  bool get localizacaoVazia =>
      cep.text.trim().isEmpty &&
      endereco.text.trim().isEmpty &&
      cidade.text.trim().isEmpty &&
      estado.text.trim().isEmpty;

  XFile? _capa;
  XFile? get capa => _capa;

  final List<XFile> _galeria = [];
  List<XFile> get galeria => List.unmodifiable(_galeria);

  void definirCapa(XFile? foto) {
    _capa = foto;
    _recalcularRascunho();
    notifyListeners();
  }

  void adicionarFoto(XFile foto) {
    if (_galeria.length >= maxFotos) return;
    _galeria.add(foto);
    _recalcularRascunho();
    notifyListeners();
  }

  void removerFoto(XFile foto) {
    _galeria.remove(foto);
    _recalcularRascunho();
    notifyListeners();
  }

  List<CategoriaModel> _categorias = [];
  List<CategoriaModel> get categorias => _categorias;

  bool _carregandoCategorias = true;
  bool get carregandoCategorias => _carregandoCategorias;

  String? _erroCategorias;
  String? get erroCategorias => _erroCategorias;

  final List<int> _selecionadas = [];
  List<int> get selecionadas => List.unmodifiable(_selecionadas);

  Future<void> carregarCategorias() async {
    _carregandoCategorias = true;
    _erroCategorias = null;
    notifyListeners();

    try {
      _categorias = await _categoriaService.getAll();
    } on AppException catch (e) {
      _erroCategorias = e.message;
    } catch (_) {
      _erroCategorias = 'Não foi possível carregar as categorias.';
    } finally {
      _carregandoCategorias = false;
      notifyListeners();
    }
  }

  bool alternarCategoria(CategoriaModel categoria) {
    if (_selecionadas.contains(categoria.id)) {
      _selecionadas.remove(categoria.id);
    } else {
      if (_selecionadas.length >= maxCategorias) return false;
      _selecionadas.add(categoria.id);
    }
    _recalcularRascunho();
    notifyListeners();
    return true;
  }

  bool _enviando = false;
  bool get enviando => _enviando;

  String? _erro;
  String? get erro => _erro;

  void limparErro() {
    if (_erro == null) return;
    _erro = null;
    notifyListeners();
  }

  final ValueNotifier<bool> temRascunho = ValueNotifier(false);

  void _recalcularRascunho() {
    final preenchido = campos.any((c) => c.text.trim().isNotEmpty) ||
        _capa != null ||
        _galeria.isNotEmpty ||
        _selecionadas.isNotEmpty;
    if (temRascunho.value != preenchido) temRascunho.value = preenchido;
  }

  String? impedimentoDaEtapa() {
    switch (_etapa) {
      case StoreRegisterStep.identidade:
        if (_capa == null) {
          return 'Adicione uma foto de destaque para o seu comércio.';
        }
      case StoreRegisterStep.localizacao:
        break;
      case StoreRegisterStep.exposicao:
        if (_selecionadas.isEmpty) return 'Selecione pelo menos uma categoria.';
    }
    return null;
  }

  String? avisoFotos;

  bool nasceuSemLocalizacao = false;

  Future<StoreDto?> enviar() async {
    if (_enviando) return null;

    _enviando = true;
    _erro = null;
    avisoFotos = null;
    notifyListeners();

    try {
      final (latitude, longitude) = await _geocodificarEndereco();

      final temLocalizacao = latitude != null && longitude != null;
      nasceuSemLocalizacao = !temLocalizacao;

      final loja = await _storeService.create(
        StoreCreateRequest(
          nome: nome.text.trim(),
          descricao: _textoOuNulo(descricao),
          statusLoja: temLocalizacao ? 'ATIVA' : 'INATIVA',
          categoriaIds: List<int>.from(_selecionadas),
          endereco: _textoOuNulo(endereco),
          cidade: _textoOuNulo(cidade),
          estado: _textoOuNulo(estado)?.toUpperCase(),
          cep: _textoOuNulo(cep),
          latitude: latitude,
          longitude: longitude,
        ),
      );

      try {
        if (_capa != null) {
          await _storeService.uploadImagemCapa(loja.id, _capa!);
        }
        if (_galeria.isNotEmpty) {
          await _storeService.uploadGaleria(loja.id, _galeria);
        }
      } catch (_) {
        avisoFotos = 'Loja cadastrada, mas houve um erro ao enviar as fotos. '
            'Tente novamente na edição da loja.';
      }

      temRascunho.value = false;
      return loja;
    } on AppException catch (e) {
      _erro = e.message;
      return null;
    } catch (_) {
      _erro = 'Erro ao cadastrar loja. Tente novamente.';
      return null;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  Future<(double?, double?)> _geocodificarEndereco() async {
    if (kIsWeb) return (null, null);
    if (endereco.text.trim().isEmpty && cidade.text.trim().isEmpty) {
      return (null, null);
    }
    try {
      final query = '${endereco.text.trim()}, '
          '${cidade.text.trim()} - ${estado.text.trim()}, Brasil';
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isEmpty) return (null, null);
      return (locations.first.latitude, locations.first.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  static String? _textoOuNulo(TextEditingController controller) {
    final texto = controller.text.trim();
    return texto.isEmpty ? null : texto;
  }

  @override
  void dispose() {
    for (final controller in campos) {
      controller.removeListener(_recalcularRascunho);
      controller.dispose();
    }
    temRascunho.dispose();
    super.dispose();
  }
}
