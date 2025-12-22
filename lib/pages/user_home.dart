import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/core/theme/colors_palette.dart';

import 'package:map_food/widgets/chat_input.dart';
import 'package:map_food/widgets/icon_card.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final TextEditingController controller = TextEditingController();
  final FocusNode chatFocus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    chatFocus.dispose();
    super.dispose();
  }

  void _openLocationSheet(BuildContext context) {
    final textScale = MediaQuery.textScaleFactorOf(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Escolha uma localização',
                style: TextStyle(
                  fontSize: 18 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(LucideIcons.locate),
                      title: Text(
                        'Usar localização atual',
                        style: TextStyle(fontSize: 14 * textScale),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(LucideIcons.building2),
                      title: Text(
                        'São Paulo',
                        style: TextStyle(fontSize: 14 * textScale),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(LucideIcons.building2),
                      title: Text(
                        'Campinas',
                        style: TextStyle(fontSize: 14 * textScale),
                      ),
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.textScaleFactorOf(context);

    final List<Map<String, dynamic>> items = [
      {"icon": LucideIcons.messageSquare, "label": "Assistente"},
      {"icon": LucideIcons.user, "label": "Perfil"},
      {"icon": LucideIcons.heart, "label": "Favoritos"},
      {"icon": LucideIcons.map, "label": "Mapa"},
      {"icon": LucideIcons.heartHandshake, "label": "Doações"},
      {"icon": LucideIcons.settings, "label": "Ajustes"},
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorsPalette.brancoOff,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// INPUT
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.01,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: ChatInput(
                          controller: controller,
                          focusNode: chatFocus,
                          onSend: () {},
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.only(top: 24),
                        onPressed: () {},
                        icon: Icon(
                          Icons.notifications_none_rounded,
                          size: size.width * 0.07,
                          color: ColorsPalette.cinzaBg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _sectionTitle('Acesso rápido', textScale),

              /// CARDS HORIZONTAIS
              SliverToBoxAdapter(
                child: SizedBox(
                  height: size.width * 0.22,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: size.width * 0.04),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return IconCard(
                        icon: item["icon"],
                        label: item["label"],
                        onTap: () {},
                      );
                    },
                  ),
                ),
              ),

              /// CARD + LOCALIZAÇÃO
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.02,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(child: _fakeCard()),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openLocationSheet(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsPalette.branco,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.mapPin,
                                  color: ColorsPalette.roxoVivo,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Limeira - SP',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14 * textScale),
                                  ),
                                ),
                                const Icon(LucideIcons.chevronDown, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _sectionTitle('Em alta', textScale),

              /// AQUI ESTAVA O ERRO – AGORA CORRETO
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                sliver: SliverToBoxAdapter(child: _fakeCard()),
              ),

              _sectionTitle('Recomendações', textScale),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => _fakeCard(),
                    childCount: 3,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        )
      ,
      
      ),
    );
  }

  /// CARD QUADRADO DE VERDADE
  Widget _fakeCard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _sectionTitle(String text, double scale) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: ColorsPalette.cinzaBg.withOpacity(0.85),
          ),
        ),
      ),
    );
  }
}
