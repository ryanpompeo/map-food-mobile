import 'package:flutter/material.dart';
import 'package:map_food/core/errors/exception.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_dimensions.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';
import 'package:map_food/core/ui/theme/map_food_colors.dart';
import 'package:map_food/core/ui/widgets/app_toast.dart';
import 'package:map_food/core/ui/widgets/confirm_delete_dialog.dart';
import 'package:map_food/core/ui/widgets/confirm_dialog.dart';
import 'package:map_food/core/ui/widgets/menu_list_tile.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class StoreAdvancedPage extends StatefulWidget {
  final StoreDto store;

  final ValueChanged<StoreDto>? onStoreUpdated;

  const StoreAdvancedPage({super.key, required this.store, this.onStoreUpdated});

  @override
  State<StoreAdvancedPage> createState() => _StoreAdvancedPageState();
}

class _StoreAdvancedPageState extends State<StoreAdvancedPage> {
  final _storeService = StoreService();

  late StoreDto _store = widget.store;
  bool _excluindo = false;
  bool _inativando = false;

  bool get _suspensa => _store.status == StatusLoja.suspensa;
  bool get _ativa => _store.status == StatusLoja.ativa;

  Future<void> _inativar() async {
    if (_inativando) return;

    final confirmou = await confirmarAcao(
      context,
      icone: AppIcons.eyeSlash,
      titulo: 'Inativar loja',
      mensagem: '"${_store.nome}" sai do mapa e das buscas até você reativá-la — '
          'nada é apagado: avaliações, fotos e cadastro continuam como estão',
      labelConfirmar: 'Inativar',
    );
    if (!confirmou || !mounted) return;

    setState(() => _inativando = true);
    try {
      final atualizada = await _storeService.atualizarStatus(_store, StatusLoja.inativa);
      if (!mounted) return;
      setState(() => _store = atualizada);
      widget.onStoreUpdated?.call(atualizada);
      AppToast.success(context, 'Loja inativada');
    } on AppException catch (e) {
      if (mounted) AppToast.error(context, e.message);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível inativar a loja');
      }
    } finally {
      if (mounted) setState(() => _inativando = false);
    }
  }

  Future<void> _excluir() async {
    if (_excluindo) return;

    final confirmou = await confirmarExclusaoLoja(context, _store.nome);
    if (!confirmou || !mounted) return;

    setState(() => _excluindo = true);
    try {
      await _storeService.excluirLoja(_store.id);
      if (!mounted) return;
      AppToast.success(context, 'Loja excluída');
      Navigator.pop(context, true);
    } on AppException catch (e) {
      if (mounted) AppToast.error(context, e.message);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível excluir a loja');
      }
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(AppIcons.caretLeft, color: ColorsPalette.redComponents),
        ),
        title: Text(
          'Configurações avançadas',
          style: AppText.subtitulo(context).copyWith(
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: Spacing.xxl),
        children: [
          const SizedBox(height: Spacing.base),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text(
              _store.nome,
              style: AppText.h2(context),
            ),
          ),
          const SizedBox(height: Spacing.xl),

          const MenuSectionLabel(label: 'Situação'),
          if (_suspensa)
            _Aviso(
              icone: AppIcons.warningCircle,
              texto: 'Loja suspensa pela moderação — não aparece no mapa e não pode '
                  'ser aberta nem excluída por aqui, só a equipe do MapFood reverte',
            )
          else if (_inativando)
            const _CarregandoLinha()
          else if (_ativa)
            MenuListTile(
              icon: AppIcons.eyeSlash,
              title: 'Inativar loja',
              subtitle: 'Sai do mapa até você reativar — nada é apagado',
              onTap: _inativar,
            )
          else
            _Aviso(
              icone: AppIcons.eyeSlash,
              texto: 'Loja inativa: não aparece no mapa nem nas buscas — use "Abrir '
                  'loja" no painel, precisamos da sua localização na hora',
            ),

          const SizedBox(height: Spacing.lg),
          const MenuSectionLabel(label: 'Zona de risco'),
          if (_excluindo)
            const _CarregandoLinha()
          else if (!_suspensa)
            MenuListTile(
              icon: AppIcons.trash,
              title: 'Excluir loja',
              subtitle: 'Apaga a loja, as avaliações e o histórico de acessos',
              iconColor: colors.brandContent,
              iconBackgroundColor: MfColor.danger.withValues(alpha: 0.12),
              onTap: _excluir,
            ),
        ],
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icone;
  final String texto;

  const _Aviso({required this.icone, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colors = context.mapColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: AppIconSize.md, color: colors.brandContent),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                texto,
                style: AppText.secondary(context).copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarregandoLinha extends StatelessWidget {
  const _CarregandoLinha();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.lg),
      child: Center(
        child: CircularProgressIndicator(color: ColorsPalette.redComponents),
      ),
    );
  }
}
