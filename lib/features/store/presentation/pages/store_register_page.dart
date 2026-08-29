import 'dart:async';

import 'package:flutter/material.dart';
import 'package:map_food/core/ui/navigation/app_page_route.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/form_error_banner.dart';
import 'package:map_food/core/ui/widgets/image_picker_sheet.dart';
import 'package:map_food/core/ui/widgets/step_progress_header.dart';
import 'package:map_food/core/ui/widgets/unsaved_changes_guard.dart';
import 'package:map_food/core/ui/widgets/wizard_footer.dart';
import 'package:map_food/features/merchant/presentation/pages/merchant_home_page.dart';
import 'package:map_food/features/store/presentation/controllers/store_register_controller.dart';
import 'package:map_food/features/store/presentation/widgets/category_picker.dart';
import 'package:map_food/features/store/presentation/widgets/store_form_fields.dart';
import 'package:map_food/features/store/presentation/widgets/store_photos_editor.dart';

/// Cadastro da loja — a primeira tela obrigatória de quem entra como
/// comerciante (o app redireciona para cá enquanto não houver loja).
///
/// É um fluxo em três etapas, e não um formulário só, porque este é o momento
/// de **conversão**: quem chega aqui ainda não sabe se o app vale o esforço, e
/// uma tela com seis campos, editor de fotos e seletor de categorias empilhados
/// responde "muito" antes de responder "o quê". Cada etapa faz uma pergunta —
/// quem é você, onde você fica, como o cliente te encontra — e o botão que
/// conclui está sempre visível no rodapé, nunca a uma rolagem de distância.
///
/// O estado vive todo em [StoreRegisterController]; esta página é desenho e
/// navegação entre as etapas.
class StoreRegisterPage extends StatefulWidget {
  const StoreRegisterPage({super.key});

  @override
  State<StoreRegisterPage> createState() => _StoreRegisterPageState();
}

class _StoreRegisterPageState extends State<StoreRegisterPage> {
  late final StoreRegisterController _controller;
  final _pageController = PageController();

  /// Um `Form` por etapa. É o que faz a divulgação progressiva funcionar:
  /// "Continuar" valida só os campos que a pessoa acabou de ver, em vez de
  /// acusar erro num campo de outra etapa que ela nem abriu ainda.
  final _formKeys = List.generate(
    StoreRegisterStep.values.length,
    (_) => GlobalKey<FormState>(),
  );

  /// Impedimento da etapa atual (foto faltando, nenhuma categoria). Fica na
  /// tela até ser resolvido, junto do rodapé que o disparou — um toast some
  /// antes de a pessoa entender o que fazer.
  String? _aviso;

  /// O controller e o `temRascunho` notificam por canais diferentes: o
  /// primeiro em toda mudança de estado, o segundo só quando o formulário
  /// passa de vazio para preenchido (ele existe justamente para não reconstruir
  /// a tela a cada tecla). O `PopScope` depende dos **dois** — sem escutar o
  /// rascunho aqui, digitar o nome da loja não atualizaria o `canPop`, e o
  /// primeiro gesto de voltar sairia da tela levando o que foi escrito.
  late final Listenable _mudancas;

  @override
  void initState() {
    super.initState();
    _controller = StoreRegisterController()..addListener(_sincronizarPagina);
    _mudancas = Listenable.merge([_controller, _controller.temRascunho]);
    _controller.carregarCategorias();
  }

  @override
  void dispose() {
    _controller.removeListener(_sincronizarPagina);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// O `PageView` é escravo do controller: quem manda na etapa é o estado, e a
  /// animação apenas segue. Sem isso, os dois viram donos da mesma verdade e
  /// divergem no primeiro gesto interrompido.
  void _sincronizarPagina() {
    if (!_pageController.hasClients) return;
    final destino = _controller.indiceEtapa;
    if (_pageController.page?.round() == destino) return;
    _pageController.animateToPage(
      destino,
      duration: Motion.medium,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _avancar() async {
    // Fecha o teclado antes de trocar de etapa: com ele aberto, a etapa nova
    // entra espremida e a pessoa vê meia tela de conteúdo.
    FocusScope.of(context).unfocus();
    setState(() => _aviso = null);
    _controller.limparErro();

    final form = _formKeys[_controller.indiceEtapa].currentState;
    if (!(form?.validate() ?? true)) return;

    final impedimento = _controller.impedimentoDaEtapa();
    if (impedimento != null) {
      setState(() => _aviso = impedimento);
      return;
    }

    if (!_controller.naUltimaEtapa) {
      _controller.avancar();
      return;
    }

    await _concluir();
  }

  Future<void> _concluir() async {
    final loja = await _controller.enviar();
    if (!mounted || loja == null) return;

    final aviso = _controller.avisoFotos;
    if (aviso != null) AppToast.error(context, aviso);

    if (_controller.nasceuSemLocalizacao) {
      AppToast.success(
        context,
        'Loja cadastrada como Fechada — abra "Em Ronda" pra ativar com sua localização.',
      );
    }

    unawaited(Navigator.pushAndRemoveUntil(
      context,
      appPageRoute(builder: (_) => const MerchantHomePage()),
      (route) => false,
    ));
  }

  /// Voltar recua **uma etapa** antes de tentar sair do cadastro. Só na
  /// primeira etapa a saída é de verdade — e aí sim o rascunho é defendido.
  ///
  /// Um `PopScope` só, em vez do [UnsavedChangesGuard]: aninhar o guard aqui
  /// registraria dois interceptadores na mesma rota, e um gesto de voltar na
  /// etapa 2 recuaria a etapa **e** abriria o diálogo de descarte junto.
  Future<void> _aoTentarSair(bool didPop) async {
    if (didPop) return;

    if (!_controller.naPrimeiraEtapa) {
      FocusScope.of(context).unfocus();
      setState(() => _aviso = null);
      _controller.voltar();
      return;
    }

    final confirmou = await confirmarSaidaSemSalvar(context);
    if (confirmou && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return ListenableBuilder(
      listenable: _mudancas,
      builder: (context, _) {
        final podeSairDireto = _controller.naPrimeiraEtapa && !_controller.temRascunho.value;

        return PopScope(
          canPop: podeSairDireto,
          onPopInvokedWithResult: (didPop, _) => _aoTentarSair(didPop),
          child: Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleSpacing: Navigator.canPop(context) ? null : Spacing.lg,
              title: Text('Cadastrar loja', style: AppText.h2(context)),
              // O progresso mora no AppBar: fica fixo enquanto o conteúdo da
              // etapa rola por baixo, que é o único jeito de "quanto falta"
              // continuar respondido no meio do preenchimento.
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    0,
                    Spacing.lg,
                    Spacing.base,
                  ),
                  child: StepProgressHeader(
                    etapaAtual: _controller.indiceEtapa,
                    total: _controller.totalEtapas,
                    rotulo: _controller.etapa.rotulo,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: PageView(
                controller: _pageController,
                // Navega só pelo rodapé: arrastar lateralmente pularia a
                // validação da etapa e deixaria campos obrigatórios para trás.
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _EtapaIdentidade(controller: _controller, formKey: _formKeys[0], aviso: _aviso),
                  _EtapaLocalizacao(controller: _controller, formKey: _formKeys[1]),
                  _EtapaExposicao(controller: _controller, formKey: _formKeys[2], aviso: _aviso),
                ],
              ),
            ),
            bottomNavigationBar: WizardFooter(
              labelPrimario: _rotuloPrimario,
              iconePrimario: _controller.naUltimaEtapa ? AppIcons.check : null,
              onPrimario: _avancar,
              carregando: _controller.enviando,
              onVoltar: _controller.naPrimeiraEtapa ? null : _controller.voltar,
            ),
          ),
        );
      },
    );
  }

  String get _rotuloPrimario {
    if (_controller.naUltimaEtapa) return 'Concluir cadastro';
    // Endereço é opcional: com a etapa em branco, "Continuar" sugeriria que
    // falta algo ali. "Pular" diz a verdade — dá para seguir sem preencher.
    if (_controller.etapa == StoreRegisterStep.localizacao && _controller.localizacaoVazia) {
      return 'Pular por enquanto';
    }
    return 'Continuar';
  }
}

/// Moldura comum das etapas: título, apoio e conteúdo rolável.
///
/// A hierarquia é só tipografia e espaço — sem card, sem borda, sem divisória.
/// Numa etapa que faz uma pergunta de cada vez, moldura é ruído: não há nada
/// de que separar o conteúdo.
class _MolduraEtapa extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String titulo;
  final String apoio;
  final List<Widget> filhos;

  const _MolduraEtapa({
    required this.formKey,
    required this.titulo,
    required this.apoio,
    required this.filhos,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.base, Spacing.lg, Spacing.xxl),
        children: [
          Text(titulo, style: AppText.h1(context)),
          const SizedBox(height: Spacing.sm),
          Text(apoio, style: AppText.secondary(context).copyWith(height: 1.45)),
          const SizedBox(height: Spacing.xl),
          ...filhos,
        ],
      ),
    );
  }
}

class _EtapaIdentidade extends StatelessWidget {
  final StoreRegisterController controller;
  final GlobalKey<FormState> formKey;
  final String? aviso;

  const _EtapaIdentidade({
    required this.controller,
    required this.formKey,
    required this.aviso,
  });

  @override
  Widget build(BuildContext context) {
    return _MolduraEtapa(
      formKey: formKey,
      titulo: 'Sua loja',
      apoio: 'É o que o cliente vê primeiro no mapa: uma foto e o nome do seu comércio.',
      filhos: [
        StorePhotosEditor(
          editando: true,
          capaObrigatoria: true,
          capaUrl: null,
          novaCapa: controller.capa,
          galeriaSalva: const [],
          novasFotos: controller.galeria,
          maxFotos: StoreRegisterController.maxFotos,
          onEscolherCapa: () async {
            final file = await pickImageFromSheet(context);
            if (file != null) controller.definirCapa(file);
          },
          // Nesta tela não há foto salva no servidor: os dois caminhos de
          // remoção caem no mesmo descarte local.
          onRemoverCapaSalva: () {},
          onDescartarNovaCapa: () => controller.definirCapa(null),
          onAdicionarFoto: () async {
            final file = await pickImageFromSheet(context);
            if (file != null) controller.adicionarFoto(file);
          },
          onRemoverFotoSalva: (_) {},
          onDescartarNovaFoto: controller.removerFoto,
        ),
        const SizedBox(height: Spacing.xl),
        StoreIdentityFields(
          nome: controller.nome,
          descricao: controller.descricao,
          descricaoObrigatoria: true,
        ),
        if (aviso != null) ...[
          const SizedBox(height: Spacing.lg),
          FormErrorBanner(message: aviso),
        ],
      ],
    );
  }
}

class _EtapaLocalizacao extends StatelessWidget {
  final StoreRegisterController controller;
  final GlobalKey<FormState> formKey;

  const _EtapaLocalizacao({required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return _MolduraEtapa(
      formKey: formKey,
      titulo: 'Onde você fica',
      apoio: 'Opcional. Sua loja entra no mapa pela sua localização em tempo real — '
          'preencha só se quiser indicar uma área de referência.',
      filhos: [
        StoreAddressFields(
          cep: controller.cep,
          endereco: controller.endereco,
          cidade: controller.cidade,
          estado: controller.estado,
          validarFormatoCep: true,
        ),
      ],
    );
  }
}

class _EtapaExposicao extends StatelessWidget {
  final StoreRegisterController controller;
  final GlobalKey<FormState> formKey;
  final String? aviso;

  const _EtapaExposicao({
    required this.controller,
    required this.formKey,
    required this.aviso,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return _MolduraEtapa(
      formKey: formKey,
      titulo: 'Como você aparece',
      apoio: 'As categorias são o filtro que o cliente usa no mapa para chegar até você.',
      filhos: [
        CategoryPicker(
          categorias: controller.categorias,
          selecionadas: controller.selecionadas,
          carregando: controller.carregandoCategorias,
          erro: controller.erroCategorias,
          onRetry: controller.carregarCategorias,
          maxSelecao: StoreRegisterController.maxCategorias,
          onLimiteExcedido: () => AppToast.error(
            context,
            'Escolha no máximo ${StoreRegisterController.maxCategorias} categorias.',
          ),
          // O limite já é barrado pelo próprio picker (via `onLimiteExcedido`),
          // então aqui o toque nunca chega recusado.
          onToggle: controller.alternarCategoria,
        ),
        const SizedBox(height: Spacing.xxl),
        // Última coisa antes de concluir: como a loja entra no ar. É a
        // mecânica que mais confunde quem chega — sem ela, o comerciante
        // termina o cadastro achando que já está no mapa.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(AppIcons.navigationArrow, size: AppIconSize.md, color: colors.textTertiary),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                'Depois do cadastro, você abre a loja na aba "Ronda". É quando sua '
                'posição passa a aparecer no mapa dos clientes — e acompanha você '
                'enquanto estiver aberta.',
                style: AppText.secondary(context).copyWith(height: 1.45),
              ),
            ),
          ],
        ),
        if (aviso != null || controller.erro != null) ...[
          const SizedBox(height: Spacing.lg),
          FormErrorBanner(message: aviso ?? controller.erro),
        ],
      ],
    );
  }
}
