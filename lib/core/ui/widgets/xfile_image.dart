import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
