import 'package:flutter/material.dart';
import 'package:map_food/core/ui/theme/app_colors.dart';
import 'package:map_food/core/ui/theme/app_icons.dart';
import 'package:map_food/core/ui/theme/category_colors.dart';

/// Faixa decorativa desenhada em código (gradiente + blobs de cor + ícone),
/// sem depender de foto/ilustração externa — usada no topo das telas de
/// autenticação (login, cadastro), que antes eram 100% tipografia + campos
/// empilhados, sem nenhum elemento gráfico. Blobs usam tons da paleta de
/// categoria (`category_colors.dart`) pra ecoar a mesma identidade cromática
/// do resto do app, em vez de introduzir cores novas isoladas.
class AuthHeroBand extends StatelessWidget {
  final double height;

  const AuthHeroBand({super.key, this.height = 132.0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40.0),
        bottomRight: Radius.circular(40.0),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorsPalette.redComponents, Color(0xFF7A0E13)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30.0, right: -20.0,
                child: _blob(categoriaCores['Bebidas']!, 110.0),
              ),
              Positioned(
                bottom: -40.0, left: -10.0,
                child: _blob(Colors.white, 90.0),
              ),
              Positioned(
                top: 10.0, left: -20.0,
                child: _blob(categoriaCores['Gelatos e Açaí']!, 60.0),
              ),
              Center(
                child: Icon(AppIcons.mapPin, size: 40.0, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.18)),
    );
  }
}
