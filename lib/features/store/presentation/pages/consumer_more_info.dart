import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/consumer/data/models/consumer_register_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/reviews/presentation/pages/user_review.dart';

class ConsumerMoreInfo extends StatefulWidget {
  final StoreDto store;
  final ConsumerRegisterRequest? data;

  const ConsumerMoreInfo({super.key, required this.store, this.data});

  @override
  State<ConsumerMoreInfo> createState() => _ConsumerMoreInfoState();
}

class _ConsumerMoreInfoState extends State<ConsumerMoreInfo> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  UserReview? _minhaAvaliacao;
  String _nomeLogado = "Carregando...";

  // Mock estático de avaliações existentes desta loja
  final List<Map<String, dynamic>> _avaliacoesMock = const [
    {
      'nome': 'Carlos Silva',
      'estrelas': 5,
      'comentario':
          'Sensacional! O pedido superou as expectativas e o atendimento foi rápido.',
      'data': 'Ontem',
    },
    {
      'nome': 'Ana Beatriz',
      'estrelas': 4,
      'comentario':
          'Muito bom, a qualidade é excelente. Único ponto é que a fila estava um pouco grande no local.',
      'data': 'Há 2 dias',
    },
    {
      'nome': 'Felipe Martins',
      'estrelas': 5,
      'comentario':
          'Recomendo de olhos fechados. Preço justo e muito saboroso.',
      'data': 'Há 1 semana',
    },
  ];

  @override
  void initState() {
    super.initState();
    _minhaAvaliacao = ReviewRepository.buscarAvaliacao(widget.store.nome);
    _carregarUsuarioLogado();
  }

  Future<void> _carregarUsuarioLogado() async {
    if (widget.data != null && widget.data!.nome.isNotEmpty) {
      setState(() => _nomeLogado = widget.data!.nome);
      return;
    }

    final session = await AuthStorage.getSession();
    if (mounted) {
      setState(() {
        _nomeLogado = session?.nome ?? "Consumidor";
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _confirmarAvaliacao() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecione pelo menos uma estrela para avaliar."),
          backgroundColor: ColorsPalette.redComponents,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      "Publicar avaliação",
                      style: AppText.titulo(
                        context,
                      ).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Deseja confirmar o envio da sua avaliação de $_rating estrela(s)?",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.black),
                ),
                if (_commentController.text.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      '"${_commentController.text.trim()}"',
                      style: AppText.corpo(context).copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancelar",
                        style: AppText.botao(
                          context,
                        ).copyWith(color: Colors.grey.shade700),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _efetivarEnvio();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsPalette.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: const Text(
                        "Publicar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _efetivarEnvio() {
    final review = UserReview(
      userName: _nomeLogado,
      rating: _rating,
      comment: _commentController.text.trim(),
      date: DateTime.now(),
    );

    setState(() {
      _minhaAvaliacao = review;
    });

    ReviewRepository.salvarAvaliacao(widget.store.nome, review);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Avaliação registrada com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _abrirModalDenuncia() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String motivoSelecionado = 'Outro';
        final TextEditingController descricaoDenunciaController =
            TextEditingController();

        final List<String> motivos = [
          'Conteúdo inapropriado',
          'Fraude ou golpe',
          'Informações falsas',
          'Spam',
          'Outro',
        ];

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSpacing.lg),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.flag,
                                color: ColorsPalette.redComponents,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Denunciar loja",
                                style: AppText.titulo(context).copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Seu relatório será analisado pela nossa equipe. Obrigado por manter a plataforma segura.",
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: Colors.brown.shade800, fontSize: 13),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "Motivo",
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: ColorsPalette.redComponents.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.2,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: motivoSelecionado,
                            isExpanded: true,
                            dropdownColor: const Color(0xFFFCF9F9),
                            borderRadius: BorderRadius.circular(12.0),
                            icon: const Icon(
                              LucideIcons.chevronDown,
                              size: 18,
                              color: Colors.black87,
                            ),
                            items: motivos.map((String motivo) {
                              return DropdownMenuItem<String>(
                                value: motivo,
                                child: Text(
                                  motivo,
                                  style: AppText.corpo(
                                    context,
                                  ).copyWith(color: Colors.black87),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setModalState(
                                  () => motivoSelecionado = newValue,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "Descrição",
                        style: AppText.legenda(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: descricaoDenunciaController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Descreva o problema com detalhes...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.all(16.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: ColorsPalette.redComponents.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: ColorsPalette.redComponents.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(
                              color: ColorsPalette.redComponents,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancelar",
                              style: AppText.botao(
                                context,
                              ).copyWith(color: Colors.brown.shade800),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Denúncia enviada."),
                                  backgroundColor: ColorsPalette.redComponents,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsPalette.redComponents,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Enviar denúncia",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 320.0,
                floating: false,
                pinned: true,
                surfaceTintColor: ColorsPalette.whiteBackground,
                backgroundColor: ColorsPalette.whiteBackground,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsPalette.whiteBackground.withValues(
                        alpha: 0.85,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.chevronLeft,
                        color: ColorsPalette.redComponents,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: ColorsPalette.whiteBackground,
                        ),
                        child:
                            widget.store.imagens != null &&
                                widget.store.imagens!.isNotEmpty
                            ? ClipRRect(
                                child: Image.network(
                                  widget.store.imagens![0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          LucideIcons.image,
                                          size: 64.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  LucideIcons.image,
                                  size: 64.0,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.store.nome,
                              style: AppText.subtitulo(context).copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 24.0,
                                color: ColorsPalette.black,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _abrirModalDenuncia,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: ColorsPalette.redComponents.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.flag,
                                    size: 14,
                                    color: ColorsPalette.redComponents,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Denunciar",
                                    style: AppText.legenda(context).copyWith(
                                      color: ColorsPalette.redComponents,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        "Sobre o local",
                        style: AppText.subtitulo(context).copyWith(
                          fontWeight: FontWeight.w900,
                          color: ColorsPalette.black,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        widget.store.descricao ??
                            "O vendedor não adicionou uma descrição detalhada para este comércio.",
                        style: AppText.corpo(
                          context,
                        ).copyWith(color: ColorsPalette.greyText, height: 1.5),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Galeria de fotos",
                            style: AppText.subtitulo(context).copyWith(
                              fontWeight: FontWeight.w900,
                              color: ColorsPalette.black,
                            ),
                          ),
                          Text(
                            "${widget.store.imagens?.length ?? 0} fotos",
                            style: AppText.legenda(context).copyWith(
                              color: ColorsPalette.greyText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 140.0,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          clipBehavior: Clip.none,
                          itemCount: widget.store.imagens?.length ?? 0,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12.0),
                          itemBuilder: (context, index) {
                            return Container(
                              width: 140.0,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Image.network(
                                  widget.store.imagens![index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          LucideIcons.image,
                                          color: Colors.grey,
                                          size: 32.0,
                                        ),
                                      ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                      const Divider(thickness: 0.2),
                      const SizedBox(height: AppSpacing.lg),

                      // Seção das avaliações gerais mockadas
                      _buildAvaliacoesSection(),

                      const SizedBox(height: AppSpacing.xxl),
                      const Divider(thickness: 0.2),
                      const SizedBox(height: AppSpacing.lg),

                      // Fluxo de avaliação condicional do usuário logado
                      if (_minhaAvaliacao == null)
                        _buildFormularioAvaliacao()
                      else
                        _buildAvaliacaoConcluida(),

                      const SizedBox(height: 120.0),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Botão flutuante fixo mapeado na stack superior
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.xl,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
              ),
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsPalette.redComponents.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsPalette.redComponents,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    elevation: 0,
                  ),
                  child: Center(
                    child: Text(
                      "Visualizar no mapa",
                      style: AppText.botao(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvaliacoesSection() {
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
                  "O que os clientes dizem",
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.greyText),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.store.avaliacao?.toString() ?? "4.8",
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
        ..._avaliacoesMock.map((review) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.grey.shade200),
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
                          backgroundColor: Colors.grey.shade100,
                          child: Text(
                            review['nome'][0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review['nome'],
                          style: AppText.corpo(
                            context,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      review['data'],
                      style: AppText.legenda(
                        context,
                      ).copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['estrelas']
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  review['comentario'],
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFormularioAvaliacao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Avalie este local",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Compartilhe sua experiência com outros usuários.",
          style: AppText.corpo(context).copyWith(color: ColorsPalette.greyText),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  index < _rating
                      ? Icons.star_rate_rounded
                      : Icons.star_border_rounded,
                  color: index < _rating ? Colors.amber : Colors.grey.shade300,
                  size: 48.0,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Deixe um comentário sobre os produtos ou atendimento...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: ColorsPalette.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: ColorsPalette.black),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _confirmarAvaliacao,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsPalette.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              elevation: 0,
            ),
            child: Text(
              "Confirmar Avaliação",
              style: AppText.botao(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvaliacaoConcluida() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sua Avaliação",
          style: AppText.subtitulo(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: ColorsPalette.black),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
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
                        backgroundColor: Colors.grey.shade100,
                        child: const Icon(LucideIcons.user, color: Colors.grey),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _nomeLogado,
                        style: AppText.corpo(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorsPalette.black,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rate_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _minhaAvaliacao!.rating.toString(),
                          style: AppText.legenda(context).copyWith(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_minhaAvaliacao!.comment.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _minhaAvaliacao!.comment,
                  style: AppText.corpo(
                    context,
                  ).copyWith(color: ColorsPalette.greyText, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
