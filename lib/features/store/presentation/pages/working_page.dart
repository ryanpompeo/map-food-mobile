import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/storage/auth_storage.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/features/store/data/models/store_create_request.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class WorkingPage extends StatefulWidget {
  final StoreDto store;

  const WorkingPage({super.key, required this.store});

  @override
  State<WorkingPage> createState() => _WorkingPageState();
}

class _WorkingPageState extends State<WorkingPage> {
  late bool _lojaAberta;
  bool _emRonda = false;
  bool _isUpdatingStatus = false;

  final _storeService = StoreService();

  @override
  void initState() {
    super.initState();
    _lojaAberta = widget.store.statusLoja == 'ATIVA';
  }

  Future<void> _toggleLojaStatus(bool val) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    try {
      final session = await AuthStorage.getSession();
      if (session == null) return;

      final novoStatus = val ? 'ATIVA' : 'INATIVA';
      // PUT /lojas/{id} faz merge campo-a-campo no backend (diferente de
      // /comerciantes e /consumidores), então reenviar nome/descricao/
      // categorias existentes é seguro e não apaga os demais dados da loja.
      await _storeService.update(
        widget.store.id,
        StoreCreateRequest(
          nome: widget.store.nome,
          descricao: widget.store.descricao,
          statusLoja: novoStatus,
          categoriaIds: widget.store.categoriaIds,
        ),
      );

      if (mounted) {
        setState(() {
          _lojaAberta = val;
          if (!val) _emRonda = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao alterar status da loja.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  // "Ronda" (compartilhamento de localização em tempo real) ainda não tem
  // suporte na API — Loja não possui esse campo no backend. Mantido como
  // estado local até o endpoint existir, para não expor um toggle que
  // sempre falha.
  void _toggleRonda(bool val) {
    setState(() => _emRonda = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsPalette.whiteBackground,
      appBar: AppBar(
        backgroundColor: ColorsPalette.whiteBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(),
        title: Text(
          widget.store.nome,
          style: AppText.titulo(context).copyWith(
            fontWeight: FontWeight.w900,
            color: ColorsPalette.black,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(child: _buildLojaStatusCard()),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildRondaStatusCard()),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              "Sua localização",
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
                color: ColorsPalette.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                image: _emRonda
                    ? const DecorationImage(
                        image: NetworkImage(
                          'https://www.transparenttextures.com/patterns/cubes.png',
                        ),
                        opacity: 0.1,
                        repeat: ImageRepeat.repeat,
                      )
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: _emRonda
                            ? ColorsPalette.redComponents.withValues(alpha: 0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _emRonda
                            ? LucideIcons.radioReceiver
                            : LucideIcons.mapPinOff,
                        size: 56.0,
                        color: _emRonda
                            ? ColorsPalette.redComponents
                            : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      _emRonda
                          ? "Compartilhando localização..."
                          : "Mapa inativo.\nInicie a ronda para rastrear",
                      textAlign: TextAlign.center,
                      style: AppText.corpo(context).copyWith(
                        color: _emRonda
                            ? ColorsPalette.black
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 120.0),
        ],
      ),
    );
  }

  Widget _buildLojaStatusCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _lojaAberta ? ColorsPalette.black : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: _lojaAberta
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
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
              _isUpdatingStatus
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _lojaAberta
                            ? Colors.white
                            : ColorsPalette.redComponents,
                      ),
                    )
                  : Switch(
                      value: _lojaAberta,
                      activeThumbColor: ColorsPalette.whiteBackground,
                      activeTrackColor: ColorsPalette.redComponents,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade200,
                      onChanged: _toggleLojaStatus,
                    ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _lojaAberta ? "Loja Aberta" : "Loja Fechada",
            style: AppText.corpo(context).copyWith(
              fontWeight: FontWeight.w800,
              color: _lojaAberta ? Colors.white : ColorsPalette.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _lojaAberta ? "Visível aos clientes" : "Invisível no mapa",
            style: AppText.legenda(context).copyWith(
              color: _lojaAberta ? Colors.grey.shade400 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRondaStatusCard() {
    final bool canActivateRonda = _lojaAberta;

    return Opacity(
      opacity: canActivateRonda ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _emRonda ? ColorsPalette.redComponents : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: _emRonda
              ? [
                  BoxShadow(
                    color: ColorsPalette.redComponents.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
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
                  onChanged: canActivateRonda ? _toggleRonda : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Em Ronda",
              style: AppText.corpo(context).copyWith(
                fontWeight: FontWeight.w800,
                color: _emRonda ? Colors.white : ColorsPalette.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _emRonda ? "Atualizando GPS" : "Posição fixa",
              style: AppText.legenda(context).copyWith(
                color: _emRonda ? Colors.white70 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
