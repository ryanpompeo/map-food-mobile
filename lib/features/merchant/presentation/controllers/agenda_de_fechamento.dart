import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:map_food/core/notificacoes/avisos_da_loja.dart';
import 'package:map_food/core/storage/prazo_abertura_storage.dart';
import 'package:map_food/features/merchant/presentation/controllers/ronda_manager.dart';
import 'package:map_food/features/store/data/models/status_loja.dart';
import 'package:map_food/features/store/data/models/store_dto.dart';
import 'package:map_food/features/store/data/services/store_service.dart';

class AgendaDeFechamento {
  AgendaDeFechamento({
    StoreService? storeService,
    DateTime Function()? agora,
    Aviso? avisar,
    this.aoFechar,
    this.minimo = const Duration(minutes: 30),
    this.maximo = const Duration(hours: 12),
  })  : _storeService = storeService ?? StoreService(),
        _agora = agora ?? DateTime.now,
        _avisar = avisar ?? AvisosDaLoja.fechouNoHorario;

  static final AgendaDeFechamento instance =
      AgendaDeFechamento(aoFechar: (lojaId) => RondaManager.instance.soltar(lojaId));

  final StoreService _storeService;
  final DateTime Function() _agora;
  final Aviso _avisar;
  final void Function(int lojaId)? aoFechar;
  final Duration minimo;
  final Duration maximo;

  final Map<int, Timer> _relogios = {};
  final Map<int, ValueNotifier<DateTime?>> _prazos = {};

  final ValueNotifier<int?> lojaFechadaPeloPrazo = ValueNotifier<int?>(null);

  ValueListenable<DateTime?> prazoDe(int lojaId) => _notificadorDe(lojaId);

  DateTime get maisCedoPossivel => _agora().add(minimo);

  DateTime get maisTardePossivel => _agora().add(maximo);

  Future<DateTime> agendar(int lojaId, DateTime encerraEm) async {
    final quando = _dentroDosLimites(encerraEm);
    final prazos = await PrazoAberturaStorage.ler();
    prazos[lojaId] = quando;
    await PrazoAberturaStorage.salvar(prazos);
    _armar(lojaId, quando);
    return quando;
  }

  Future<DateTime> prorrogar(int lojaId, Duration extra) {
    final atual = _notificadorDe(lojaId).value ?? _agora();
    return agendar(lojaId, atual.add(extra));
  }

  Future<void> cancelar(int lojaId) async {
    _relogios.remove(lojaId)?.cancel();
    _notificadorDe(lojaId).value = null;
    final prazos = await PrazoAberturaStorage.ler();
    if (prazos.remove(lojaId) != null) await PrazoAberturaStorage.salvar(prazos);
  }

  Future<void> retomar(List<StoreDto> lojasDoComerciante) async {
    final prazos = await PrazoAberturaStorage.ler();
    if (prazos.isEmpty) return;
    final abertas = <int, StoreDto>{
      for (final loja in lojasDoComerciante)
        if (loja.status == StatusLoja.ativa) loja.id: loja,
    };
    for (final entrada in prazos.entries.toList()) {
      if (!abertas.containsKey(entrada.key)) {
        await cancelar(entrada.key);
        continue;
      }
      if (entrada.value.isAfter(_agora())) {
        _armar(entrada.key, entrada.value);
        continue;
      }
      await _fechar(entrada.key);
    }
  }

  Future<void> esquecerTudo() async {
    for (final relogio in _relogios.values) {
      relogio.cancel();
    }
    _relogios.clear();
    for (final prazo in _prazos.values) {
      prazo.value = null;
    }
    await PrazoAberturaStorage.limpar();
  }

  DateTime _dentroDosLimites(DateTime encerraEm) {
    final cedoDemais = maisCedoPossivel;
    final tardeDemais = maisTardePossivel;
    if (encerraEm.isBefore(cedoDemais)) return cedoDemais;
    if (encerraEm.isAfter(tardeDemais)) return tardeDemais;
    return encerraEm;
  }

  void _armar(int lojaId, DateTime quando) {
    _relogios.remove(lojaId)?.cancel();
    _notificadorDe(lojaId).value = quando;
    final falta = quando.difference(_agora());
    _relogios[lojaId] = Timer(
      falta.isNegative ? Duration.zero : falta,
      () => unawaited(_fechar(lojaId)),
    );
  }

  Future<void> _fechar(int lojaId) async {
    final prazo = _notificadorDe(lojaId).value;
    _relogios.remove(lojaId)?.cancel();
    aoFechar?.call(lojaId);
    try {
      final loja = await _storeService.getResumo(lojaId);
      if (loja.status == StatusLoja.ativa) {
        await _storeService.atualizarStatus(loja, StatusLoja.inativa);
        lojaFechadaPeloPrazo.value = lojaId;
        unawaited(_avisar(_motivoDoFechamento(loja.nome, prazo)));
      }
    } catch (_) {
    } finally {
      await cancelar(lojaId);
    }
  }

  static String _motivoDoFechamento(String nome, DateTime? prazo) {
    if (prazo == null) return '$nome fechou no horário que você marcou.';
    final hora = prazo.hour.toString().padLeft(2, '0');
    final minuto = prazo.minute.toString().padLeft(2, '0');
    return '$nome fechou às $hora:$minuto, como você tinha marcado.';
  }

  ValueNotifier<DateTime?> _notificadorDe(int lojaId) =>
      _prazos.putIfAbsent(lojaId, () => ValueNotifier<DateTime?>(null));
}
