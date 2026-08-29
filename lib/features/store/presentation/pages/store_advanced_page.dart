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
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

/// O que fica **fora** do caminho diário: ações raras e as que não têm volta.
///
/// A separação é o ponto da tela. No painel, tudo está a um toque porque é
/// usado todo dia; excluir a loja não pode dividir esse espaço com "trocar a
/// foto" — dois toques de distância é o que impede o engano.
///
/// "Inativar loja" mora aqui pelo mesmo motivo, mas do outro lado da linha: é
/// a saída de quem quer sumir do mapa por um tempo, e precisa aparecer **antes**
/// da exclusão para ser encontrada por quem chegou pensando em apagar tudo.
/// Ela grava o mesmo `INATIVA` do botão "Fechar loja" do painel — a diferença é
/// de intenção (parar por tempo indeterminado × encerrar o dia), não de estado.
class StoreAdvancedPage extends StatefulWidget {
  final StoreDto store;

  /// Loja alterada no backend (aqui, só o status) — o painel que abriu esta
  /// tela precisa refletir a mudança sem esperar um recarregamento.
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

  bool get _suspensa => _store.statusLoja == 'SUSPENSA';
  bool get _ativa => _store.statusLoja == 'ATIVA';

  Future<void> _inativar() async {
    if (_inativando) return;

    final confirmou = await confirmarAcao(
      context,
      icone: AppIcons.eyeSlash,
      titulo: 'Inativar loja',
      mensagem: '"${_store.nome}" sai do mapa e deixa de aparecer nas buscas até você '
          'reativá-la. Nada é apagado: avaliações, fotos e cadastro continuam '
          'como estão.',
      labelConfirmar: 'Inativar',
    );
    if (!confirmou || !mounted) return;

    setState(() => _inativando = true);
    try {
      final atualizada = await _storeService.atualizarStatus(_store, 'INATIVA');
      if (!mounted) return;
      setState(() => _store = atualizada);
      widget.onStoreUpdated?.call(atualizada);
      AppToast.success(context, 'Loja inativada.');
    } on AppException catch (e) {
      if (mounted) AppToast.error(context, e.message);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível inativar a loja. Tente novamente.');
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
      AppToast.success(context, 'Loja excluída.');
      // `true` avisa quem abriu esta tela que a lista de lojas mudou.
      Navigator.pop(context, true);
    } on AppException catch (e) {
      // A API recusa excluir loja SUSPENSA (403 com mensagem própria) — o
      // botão já não aparece nesse caso, mas o status pode ter mudado
      // enquanto a tela estava aberta.
      if (mounted) AppToast.error(context, e.message);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Não foi possível excluir a loja. Tente novamente.');
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
              // Sem esta explicação, o comerciante encontra uma loja
              // fora do mapa, sem botão de reabrir e sem opção de
              // excluir — e não tem como saber por quê.
              texto: 'Esta loja está suspensa pela moderação. Ela não aparece no mapa, '
                  'não pode ser aberta nem excluída por aqui — só a equipe do MapFood '
                  'pode reverter esse status.',
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
            // Reativar não cabe aqui: a loja só deve voltar para ATIVA junto de
            // uma posição fresca, senão ela fica "ativa" no banco e invisível no
            // mapa (o filtro de proximidade ignora loja sem lat/long). Quem faz
            // isso direito é o "Abrir loja" do painel, que exige o GPS antes.
            _Aviso(
              icone: AppIcons.eyeSlash,
              texto: 'Esta loja está inativa: ela não aparece no mapa nem nas buscas. '
                  'Para voltar ao mapa, use "Abrir loja" no painel — precisamos da sua '
                  'localização na hora para colocá-la de volta.',
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

/// Bloco informativo das situações em que não há ação a oferecer (loja suspensa
/// pela moderação, ou inativa e reativável só pelo painel).
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
