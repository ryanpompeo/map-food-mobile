import 'dart:math' as math;

import 'package:map_food/features/store/data/models/store_dto.dart';

List<StoreDto> buscarLojas(List<StoreDto> lojas, String termo) {
  final alvo = normalizarTexto(termo);
  if (alvo.isEmpty) return lojas;

  final pontuadas = <(int posicao, int relevancia, StoreDto loja)>[];
  for (var i = 0; i < lojas.length; i++) {
    final relevancia = _relevancia(lojas[i], alvo);
    if (relevancia != null) pontuadas.add((i, relevancia, lojas[i]));
  }

  pontuadas.sort((a, b) {
    final porRelevancia = a.$2.compareTo(b.$2);
    return porRelevancia != 0 ? porRelevancia : a.$1.compareTo(b.$1);
  });

  return pontuadas.map((p) => p.$3).toList();
}

int? _relevancia(StoreDto loja, String alvo) {
  final nome = normalizarTexto(loja.nome);
  if (nome.startsWith(alvo)) return 0;
  if (_contemPalavraQueComecaCom(nome, alvo)) return 1;
  if (nome.contains(alvo)) return 2;

  for (final categoria in loja.categoriaNomes) {
    if (normalizarTexto(categoria).contains(alvo)) return 3;
  }

  final cidade = loja.cidade;
  if (cidade != null && normalizarTexto(cidade).contains(alvo)) return 4;

  final endereco = loja.endereco;
  if (endereco != null && normalizarTexto(endereco).contains(alvo)) return 5;

  final descricao = loja.descricao;
  if (descricao != null && normalizarTexto(descricao).contains(alvo)) return 6;

  if (_pareceErroDeDigitacao(nome, alvo)) return 7;

  return null;
}

bool _contemPalavraQueComecaCom(String texto, String alvo) {
  for (final palavra in texto.split(' ')) {
    if (palavra.startsWith(alvo)) return true;
  }
  return false;
}

bool _pareceErroDeDigitacao(String nome, String alvo) {
  if (alvo.length < 4) return false;
  final limite = alvo.length >= 7 ? 2 : 1;

  for (final palavra in nome.split(' ')) {
    if (palavra.length < 3) continue;
    final trecho = palavra.length > alvo.length + limite
        ? palavra.substring(0, alvo.length + limite)
        : palavra;
    if (_distanciaLevenshtein(trecho, alvo) <= limite) return true;
  }
  return false;
}

String normalizarTexto(String texto) {
  final buffer = StringBuffer();
  for (final unidade in texto.toLowerCase().runes) {
    final caractere = String.fromCharCode(unidade);
    final indice = _comAcento.indexOf(caractere);
    buffer.write(indice >= 0 ? _semAcento[indice] : caractere);
  }
  return buffer.toString().trim();
}

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

int _distanciaLevenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var anterior = List<int>.generate(b.length + 1, (i) => i);
  var atual = List<int>.filled(b.length + 1, 0);

  for (var i = 0; i < a.length; i++) {
    atual[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final custo = a.codeUnitAt(i) == b.codeUnitAt(j) ? 0 : 1;
      atual[j + 1] = math.min(
        math.min(atual[j] + 1, anterior[j + 1] + 1),
        anterior[j] + custo,
      );
    }
    final troca = anterior;
    anterior = atual;
    atual = troca;
  }

  return anterior[b.length];
}
