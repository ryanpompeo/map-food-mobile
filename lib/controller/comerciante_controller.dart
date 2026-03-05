import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ComercianteController extends ChangeNotifier {
  double latitue = 0;
  double longitude = 0;
  String erro = '';

  ComercianteController() {
    getPosicao();
  }

  getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      latitue = posicao.latitude;
      longitude = posicao.longitude;
    } catch (e) {
      erro = 'Erro ao obter posição: $e';
    }
    notifyListeners();
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permission;

    bool ativo = await Geolocator.isLocationServiceEnabled();

    if (!ativo) {
      throw 'Serviço de localização desativado';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permissão de localização negada';
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw 'Permissão de localização permanentemente negada';
    }

    return await Geolocator.getCurrentPosition();
  }
}
