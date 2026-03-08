import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:map_food/controller/comerciante_controller.dart';
import 'package:map_food/core/theme/colors_palette.dart';

import 'package:map_food/widgets/chat_input.dart';
import 'package:map_food/widgets/icon_card.dart';
import 'package:provider/provider.dart';

class PageSemLogin extends StatefulWidget {
  const PageSemLogin({super.key});

  @override
  State<PageSemLogin> createState() => _PageSemLogin();
}

class _PageSemLogin extends State<PageSemLogin> {
  final TextEditingController controller = TextEditingController();
  final FocusNode chatFocus = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    chatFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = MediaQuery.textScaleFactorOf(context);

    final List<Map<String, dynamic>> items = [
      {"icon": LucideIcons.messageSquare, "label": "Assistente"},
      {"icon": LucideIcons.user, "label": "Criar Perfil"},
      {"icon": LucideIcons.map, "label": "Mapa"},
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
                      // IconButton(
                      //   padding: const EdgeInsets.only(top: 24),
                      //   onPressed: () {},
                      //   icon: Icon(
                      //     Icons.notifications_none_rounded,
                      //     size: size.width * 0.07,
                      //     color: ColorsPalette.cinzaBg,
                      //   ),
                      // ),
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
                      Expanded(
                        child: ChangeNotifierProvider(
                          create: (_) => ComercianteController(),
                          child: Builder(
                            builder: (context) {
                              final controller =
                                  Provider.of<ComercianteController>(context);
                              return Center(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
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
                                    child: Expanded(
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(
                                            controller.latitue,
                                            controller.longitude,
                                          ),
                                          zoom: 15,
                                        ),
                                        zoomControlsEnabled: false,
                                        myLocationEnabled: true,
                                        scrollGesturesEnabled: false,
                                        onTap: (argument) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => Scaffold(
                                                appBar: AppBar(
                                                  title: const Text('Mapa'),
                                                ),
                                                body: GoogleMap(
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                        target: LatLng(
                                                          controller.latitue,
                                                          controller.longitude,
                                                        ),
                                                        zoom: 15,
                                                      ),
                                                  zoomControlsEnabled: false,
                                                  myLocationEnabled: true,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
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
                    (_, _) => _fakeCard(),
                    childCount: 3,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ),
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
