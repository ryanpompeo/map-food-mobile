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

/// As três etapas do cadastro de loja.
///
/// A divisão não é por tamanho de formulário, é por pergunta: quem é você, onde
/// você fica, e como o cliente te encontra. Cada etapa responde uma, e é isso
/// que permite parar no meio sem ficar com um pensamento pela metade.
enum StoreRegisterStep {
  identidade('Sua loja'),
  localizacao('Onde você fica'),
  exposicao('Como você aparece');

  final String rotulo;

  const StoreRegisterStep(this.rotulo);
}

/// Estado do cadastro de loja — campos, fotos, categorias e em que etapa a
/// pessoa está.
///
/// Existe para que a página seja só desenho. Com o fluxo em etapas, o mesmo
/// dado é lido e escrito de três telas diferentes, e manter tudo em `setState`
/// espalharia a regra de "esta etapa está completa?" pelos widgets.
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

  // ───────────────────────────── etapas ─────────────────────────────

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

  /// Endereço é opcional no MapFood — muitos comércios são ambulantes. Com a
  /// etapa em branco, o botão de avançar diz "Pular por enquanto" em vez de
  /// fingir que há algo pendente ali.
  bool get localizacaoVazia =>
      cep.text.trim().isEmpty &&
      endereco.text.trim().isEmpty &&
      cidade.text.trim().isEmpty &&
      estado.text.trim().isEmpty;

  // ───────────────────────────── fotos ──────────────────────────────

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

  // ─────────────────────────── categorias ───────────────────────────

  List<CategoriaModel> _categorias = [];
  List<CategoriaModel> get categorias => _categorias;

  bool _carregandoCategorias = true;
  bool get carregandoCategorias => _carregandoCategorias;

  /// Mensagem de falha da busca — `null` quando deu certo (inclusive com lista
  /// vazia, que é outro estado).
  String? _erroCategorias;
  String? get erroCategorias => _erroCategorias;

  final List<int> _selecionadas = [];
  List<int> get selecionadas => List.unmodifiable(_selecionadas);

  /// Falha aqui não pode ser silenciosa: escolher categoria é obrigatório para
  /// concluir, e uma seção vazia deixa a pessoa presa olhando um botão que não
  /// funciona, sem nada para tocar.
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

  /// Devolve `false` quando o toque foi recusado por já estar no limite — quem
  /// chama avisa a pessoa.
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

  // ──────────────────────── envio e rascunho ────────────────────────

  bool _enviando = false;
  bool get enviando => _enviando;

  /// Erro do envio. É estado da tela, não notificação: fica visível junto do
  /// botão até ser corrigido, em vez de sumir sozinho como um toast.
  String? _erro;
  String? get erro => _erro;

  void limparErro() {
    if (_erro == null) return;
    _erro = null;
    notifyListeners();
  }

  /// Alimenta o `UnsavedChangesGuard`. `ValueNotifier` separado para o guard
  /// reconstruir sozinho, sem passar pelo `notifyListeners` da página inteira
  /// a cada tecla digitada.
  final ValueNotifier<bool> temRascunho = ValueNotifier(false);

  void _recalcularRascunho() {
    final preenchido = campos.any((c) => c.text.trim().isNotEmpty) ||
        _capa != null ||
        _galeria.isNotEmpty ||
        _selecionadas.isNotEmpty;
    if (temRascunho.value != preenchido) temRascunho.value = preenchido;
  }

  /// Impedimento da etapa atual, ou `null` se ela está pronta para avançar.
  ///
  /// Só cobre o que um `Form` não valida sozinho (foto e categorias); os
  /// campos de texto ficam com o `validator` de cada um, onde o erro aparece
  /// embaixo do campo certo.
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

  /// Cria a loja e envia as fotos.
  ///
  /// Devolve a loja criada, ou `null` se falhou — nesse caso [erro] tem a
  /// mensagem. O aviso de fotos que falharam vem em [avisoFotos], porque a
  /// loja **existe** mesmo assim e mandar tudo de volta como erro faria a
  /// pessoa tentar cadastrar de novo.
  String? avisoFotos;

  /// `true` quando a loja nasceu sem coordenadas e, portanto, `INATIVA`.
  bool nasceuSemLocalizacao = false;

  Future<StoreDto?> enviar() async {
    if (_enviando) return null;

    _enviando = true;
    _erro = null;
    avisoFotos = null;
    notifyListeners();

    try {
      final (latitude, longitude) = await _geocodificarEndereco();

      // Sem localização a loja fica invisível no mapa mesmo com status ATIVA —
      // melhor já nascer INATIVA e deixar claro que falta ativar pela ronda
      // (que captura a posição por GPS) do que criar uma loja "ativa" fantasma
      // que ninguém encontra.
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

      // A loja foi criada: não há mais rascunho a proteger, e sem zerar isto o
      // guard interceptaria a própria navegação de sucesso.
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

  /// Converte o endereço digitado em lat/lng, como ponto de referência
  /// inicial. A posição de verdade vem do GPS ao vivo quando a loja fica
  /// "Aberta" (ver a ronda do comerciante); isso aqui é só um fallback para
  /// quem quis indicar uma área.
  Future<(double?, double?)> _geocodificarEndereco() async {
    // O pacote geocoding não tem implementação web.
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
