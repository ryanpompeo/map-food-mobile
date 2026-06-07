import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/models/store/store_create_request.dart';

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
  void _confirmarEdicao() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar Loja"),
        content: const Text(
          "Deseja realmente alterar as informações do seu comércio?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Lógica de navegação para edição
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(
              "Olá, ${widget.requestData.nome}!",
              style: AppText.titulo(context),
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Editar Informações"),
                    leading: const Icon(LucideIcons.edit),
                    onTap: _confirmarEdicao,
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text("Ver Avaliações"),
                    leading: const Icon(LucideIcons.star),
                    trailing: const Icon(LucideIcons.chevronRight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Text("Dados do Comércio", style: AppText.subtitulo(context)),
            const SizedBox(height: AppSpacing.md),

            _buildReadOnlyField("Nome da Loja", widget.requestData.nome),
            _buildReadOnlyField(
              "Categoria",
              widget.requestData.categoriaIds
                      ?.map(
                        (id) => _categoriasBase.firstWhere(
                          (cat) => cat['id'] == id,
                        )['nome'],
                      )
                      .join(", ") ??
                  "Não informada",
            ),
            _buildReadOnlyField(
              "Descrição",
              widget.requestData.descricao ?? "",
            ),

            const SizedBox(height: AppSpacing.md),
            Text(
              "Foto de Destaque ID: ${widget.fotoDestaqueId}",
              style: AppText.legenda(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        initialValue: value,
        readOnly: true, // Bloqueia a edição
        enabled: false, // Visual de "desativado" (cinza)
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        style: AppText.corpo(context).copyWith(color: Colors.black87),
      ),
    );
  }
}
