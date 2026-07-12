import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_typography.dart';

/// Avatar circular com upload/remoção de foto: toque na foto para trocar,
/// toque na lixeira (quando há foto) para remover. Usado nas telas de
/// editar perfil de comerciante e consumidor.
class EditableAvatar extends StatefulWidget {
  final String? imageUrl;
  final String fallbackLetter;
  final Future<void> Function(XFile file) onUpload;
  final Future<void> Function() onRemove;

  const EditableAvatar({
    super.key,
    required this.imageUrl,
    required this.fallbackLetter,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  State<EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends State<EditableAvatar> {
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _selecionar() async {
    final foto = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (foto == null) return;
    setState(() => _isLoading = true);
    try {
      await widget.onUpload(foto);
    } catch (_) {
      _mostrarErro();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _remover() async {
    setState(() => _isLoading = true);
    try {
      await widget.onRemove();
    } catch (_) {
      _mostrarErro();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Erro ao atualizar foto. Tente novamente.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _isLoading ? null : _selecionar,
              child: Container(
                height: 80,
                width: 80,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: ColorsPalette.redComponents.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorsPalette.redComponents,
                        ),
                      )
                    : widget.imageUrl != null
                        ? Image.network(
                            widget.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallback(context),
                          )
                        : _buildFallback(context),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isLoading ? null : _selecionar,
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: ColorsPalette.redComponents,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(LucideIcons.camera, size: 14.0, color: Colors.white),
                ),
              ),
            ),
            if (widget.imageUrl != null && !_isLoading)
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: _remover,
                  child: Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                      ],
                    ),
                    child: const Icon(LucideIcons.x, size: 12.0, color: ColorsPalette.redComponents),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: Text(
        widget.fallbackLetter,
        style: AppText.titulo(context).copyWith(
          fontSize: 32,
          color: ColorsPalette.redComponents,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
