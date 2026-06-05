import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/theme/app_radius.dart';
import 'package:map_food/core/theme/app_spacing.dart';
import 'package:map_food/core/theme/app_text_styles.dart';
import 'package:map_food/core/theme/colors_palette.dart';
import 'package:map_food/pages/merchant/widgets/merchant_bottom_bar.dart';

class MerchantHomePage extends StatefulWidget {
  const MerchantHomePage({super.key});

  @override
  State<MerchantHomePage> createState() => _MerchantHomePageState();
}

class _MerchantHomePageState extends State<MerchantHomePage> {
  int _selectedIndex = 0;

  bool _lojaAberta = false;
  bool _emRonda = false;

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              _buildDashboard(),

              const Center(child: Text("Gestão de Avaliações")),

              const Center(child: Text("Perfil e Dados da Loja")),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MerchantBottomBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: ColorsPalette.whiteBackground,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hamburgueria do Zé",
                style: AppText.titulo(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: ColorsPalette.redComponents,
                ),
              ),
            ],
          ),
        ),

        // Controles Operacionais
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(child: _buildLojaStatusCard()),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildRondaStatusCard()),
            ],
          ),
        ),

        // Área do Mapa Local (Onde o comerciante está)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            "Sua Localização Atual",
            style: AppText.subtitulo(
              context,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _emRonda
                        ? LucideIcons.radioReceiver
                        : LucideIcons.mapPinOff,
                    size: 48.0,
                    color: _emRonda
                        ? ColorsPalette.redComponents
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    _emRonda
                        ? "Transmitindo GPS ao vivo..."
                        : "Mapa inativo. Inicie a ronda para rastrear.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 100.0),
      ],
    );
  }

  Widget _buildLojaStatusCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _lojaAberta ? ColorsPalette.black : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _lojaAberta ? ColorsPalette.black : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                LucideIcons.store,
                color: _lojaAberta ? Colors.white : ColorsPalette.black,
              ),
              Switch(
                value: _lojaAberta,
                activeThumbColor: ColorsPalette.whiteBackground,
                activeTrackColor: ColorsPalette.redComponents,
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
                onChanged: (val) {
                  setState(() {
                    _lojaAberta = val;

                    if (!val) _emRonda = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _lojaAberta ? "Loja Aberta" : "Loja Fechada",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w800,
              color: _lojaAberta ? Colors.white : ColorsPalette.black,
            ),
          ),
          Text(
            _lojaAberta ? "Recebendo clientes" : "Invisível no mapa",
            style: TextStyle(
              fontSize: 12.0,
              color: _lojaAberta ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRondaStatusCard() {
    final bool canActivateRonda = _lojaAberta;

    return Opacity(
      opacity: canActivateRonda ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _emRonda ? ColorsPalette.redComponents : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _emRonda
                ? ColorsPalette.redComponents
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  LucideIcons.navigation,
                  color: _emRonda ? Colors.white : ColorsPalette.black,
                ),
                Switch(
                  value: _emRonda,
                  activeThumbColor: ColorsPalette.whiteBackground,
                  activeTrackColor: ColorsPalette.black,
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade200,
                  onChanged: canActivateRonda
                      ? (val) => setState(() => _emRonda = val)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Em Ronda",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w800,
                color: _emRonda ? Colors.white : ColorsPalette.black,
              ),
            ),
            Text(
              _emRonda ? "GPS Ativado" : "GPS Pausado",
              style: TextStyle(
                fontSize: 12.0,
                color: _emRonda ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
