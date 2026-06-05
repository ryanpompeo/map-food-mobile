import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_icon_size.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _buscasRecentes = [
    'Hambúrguer artesanal',
    'Açaí',
    'Pizza',
    'Marmita',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        foregroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: ColorsPalette.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Buscar",
          style: AppText.legenda(context).copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: ColorsPalette.black,
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildSearchBar(context),
                    const SizedBox(height: AppSpacing.xl),
                    if (_buscasRecentes.isNotEmpty) _buildHistorico(context),
                    const SizedBox(height: 120.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52.0,
      decoration: BoxDecoration(
        color: ColorsPalette.whiteBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        style: AppText.corpo(
          context,
        ).copyWith(fontWeight: FontWeight.w600, color: ColorsPalette.black),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "O que vamos comer hoje?",
          hintStyle: AppText.corpo(
            context,
          ).copyWith(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          prefixIcon: Icon(
            LucideIcons.search,
            color: ColorsPalette.redComponents,
            size: AppIconSize.md,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: Colors.grey.shade400,
                    size: AppIconSize.md,
                  ),
                  onPressed: () => setState(() => _searchController.clear()),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildHistorico(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pesquisas recentes",
              style: AppText.subtitulo(context).copyWith(
                fontWeight: FontWeight.w800,
                color: ColorsPalette.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _buscasRecentes.clear();
                });
              },
              child: Text(
                "Limpar",
                style: AppText.legenda(context).copyWith(
                  color: ColorsPalette.blackDetails,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _buscasRecentes.map((termo) {
            return InkWell(
              onTap: () {
                setState(() {
                  _searchController.text = termo;
                });
              },
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: ColorsPalette.whiteBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.history,
                      size: AppIconSize.sm,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      termo,
                      style: AppText.legenda(context).copyWith(
                        color: ColorsPalette.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
