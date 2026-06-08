import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';

class MerchantDashboard extends StatefulWidget {
  final StoreCreateRequest requestData;
  final int fotoDestaqueId;
  final List<int> categoriasIds;
  final List<int> fotosGaleriaIds;

  const MerchantDashboard({
    super.key,
    required this.requestData,
    required this.fotoDestaqueId,
    required this.fotosGaleriaIds,
    required this.categoriasIds,
  });

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  // Controle de Modo de Tela
  bool _isEditing = false;

  // Controladores de Edição
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late List<int> _categoriasSelecionadas;
  int? _fotoDestaqueTemp;
  late List<int> _fotosGaleriaTemp;

  final int _maxFotosGaleria = 10;

  final List<Map<String, dynamic>> _categoriasBase = [
    {'id': 1, 'nome': 'Lanches e Hot Dogs'},
    {'id': 2, 'nome': 'Espetinhos'},
    {'id': 3, 'nome': 'Pastel e Salgados'},
    {'id': 4, 'nome': 'Doces e Sobremesas'},
    {'id': 5, 'nome': 'Bebidas'},
    {'id': 6, 'nome': 'Gelados e Açaí'},
    {'id': 7, 'nome': 'Milho e Pamonha'},
    {'id': 8, 'nome': 'Pipoca'},
  ];

  // Mock de Avaliações para testar o visual
  final List<Map<String, dynamic>> _avaliacoesMock = [
    {
      'nome': 'Carlos Silva',
      'estrelas': 5,
      'comentario':
          'Lanche sensacional! Chegou quentinho e o molho de alho é o melhor da cidade.',
      'data': 'Há 2 dias',
    },
    {
      'nome': 'Ana Beatriz',
      'estrelas': 4,
      'comentario':
          'Muito bom, mas a fila estava um pouco grande. Valeu a espera.',
      'data': 'Há 1 semana',
    },
  ];

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {
    _nomeController = TextEditingController(text: widget.requestData.nome);
    _descricaoController = TextEditingController(
      text: widget.requestData.descricao ?? "",
    );
    _categoriasSelecionadas = List.from(widget.categoriasIds);
    _fotoDestaqueTemp = widget.fotoDestaqueId;
    _fotosGaleriaTemp = List.from(widget.fotosGaleriaIds);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _abrirModalConfirmacao() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCircle,
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
                ).copyWith(color: ColorsPalette.greyText),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: Text(
                        "Cancelar",
                        style: AppText.botao(
                          context,
                        ).copyWith(color: ColorsPalette.black),
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

  void _efetivarSalvamento() {
    // Aqui você implementará a chamada para a API no futuro
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Informações atualizadas com sucesso!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _cancelarEdicao() {
    setState(() {
      _isEditing = false;
      _inicializarDados(); // Reseta para os dados originais
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header: Título e Botão de Editar
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
                        color: ColorsPalette.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.edit2,
                            size: 16,
                            color: ColorsPalette.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Editar",
                            style: AppText.legenda(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: ColorsPalette.black,
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

            // SEÇÃO 1: FOTOS
            _buildSecaoFotos(),
            const SizedBox(height: AppSpacing.xl),

            // SEÇÃO 2: DADOS DE TEXTO
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
            const SizedBox(height: AppSpacing.md),

            // SEÇÃO 3: CATEGORIAS
            _buildCategoriasSection(),

            const SizedBox(height: AppSpacing.xxl),
            const Divider(thickness: 0.5),
            const SizedBox(height: AppSpacing.lg),

            // SEÇÃO 4: AVALIAÇÕES DOS CLIENTES (Apenas exibição)
            _buildAvaliacoesSection(),

            const SizedBox(height: 120), // Respiro para a BottomBar
          ],
        ),
      ),

      floatingActionButton: _isEditing
          ? Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: FloatingActionButton.extended(
                onPressed: _abrirModalConfirmacao,
                backgroundColor: ColorsPalette.redComponents,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                icon: const Icon(
                  LucideIcons.save,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  "Salvar Mudanças",
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

  // --- WIDGETS AUXILIARES ---

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
              ? () => setState(
                  () =>
                      _fotoDestaqueTemp = DateTime.now().millisecondsSinceEpoch,
                )
              : null,
          child: Container(
            height: 160.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _fotoDestaqueTemp != null
                  ? ColorsPalette.redComponents.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: _isEditing
                    ? ColorsPalette.redComponents.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: _fotoDestaqueTemp != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      const Center(
                        child: Icon(
                          LucideIcons.image,
                          color: ColorsPalette.redComponents,
                          size: 48.0,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _fotoDestaqueTemp = null),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
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
                      Icon(
                        LucideIcons.imagePlus,
                        color: Colors.grey.shade400,
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
          "Galeria (${_fotosGaleriaTemp.length}/$_maxFotosGaleria)",
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
              if (_isEditing && _fotosGaleriaTemp.length < _maxFotosGaleria)
                GestureDetector(
                  onTap: () => setState(
                    () => _fotosGaleriaTemp.add(
                      DateTime.now().millisecondsSinceEpoch,
                    ),
                  ),
                  child: Container(
                    height: 100.0,
                    width: 100.0,
                    margin: const EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                      color: ColorsPalette.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          LucideIcons.plus,
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
              ..._fotosGaleriaTemp.map((fotoId) {
                return Container(
                  height: 100.0,
                  width: 100.0,
                  margin: const EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                    color: ColorsPalette.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          LucideIcons.image,
                          color: Colors.grey,
                          size: 32.0,
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _fotosGaleriaTemp.remove(fotoId),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(
                                LucideIcons.x,
                                size: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              if (!_isEditing && _fotosGaleriaTemp.isEmpty)
                Text(
                  "Nenhuma foto na galeria.",
                  style: AppText.legenda(context).copyWith(color: Colors.grey),
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
            style: AppText.corpo(context).copyWith(
              color: _isEditing ? ColorsPalette.black : Colors.grey.shade700,
              fontWeight: _isEditing ? FontWeight.normal : FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: _isEditing ? Colors.white : Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide(
                  color: _isEditing
                      ? ColorsPalette.redComponents.withValues(alpha: 0.3)
                      : ColorsPalette.whiteBackground,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                borderSide: BorderSide(
                  color: _isEditing ? Colors.grey.shade300 : Colors.transparent,
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
        Wrap(
          spacing: 8.0,
          runSpacing: 10.0,
          children: _categoriasBase.map((cat) {
            final isSelected = _categoriasSelecionadas.contains(cat['id']);

            // Se não estiver editando, oculta as tags que não foram selecionadas
            if (!_isEditing && !isSelected) return const SizedBox.shrink();

            return GestureDetector(
              onTap: _isEditing
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _categoriasSelecionadas.remove(cat['id']);
                        } else {
                          _categoriasSelecionadas.add(cat['id']);
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
                  color: isSelected ? ColorsPalette.black : Colors.white,
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(
                    color: isSelected
                        ? ColorsPalette.black
                        : ColorsPalette.whiteBackground,
                  ),
                ),
                child: Text(
                  cat['nome'],
                  style: AppText.legenda(context).copyWith(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
                  ).copyWith(color: ColorsPalette.greyText),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    "4.5",
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
}
