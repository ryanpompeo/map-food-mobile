import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Exibe a pré-visualização de um [XFile] recém-escolhido pelo image_picker.
/// Usa bytes (`Image.memory`) em vez de `Image.file`, já que `dart:io.File`
/// não funciona no Flutter Web.
class XFileImage extends StatelessWidget {
  final XFile file;
  final BoxFit fit;

  const XFileImage(this.file, {super.key, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Image.memory(snapshot.data!, fit: fit);
      },
    );
  }
}
