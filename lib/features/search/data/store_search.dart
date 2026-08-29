import 'dart:math' as math;

import 'package:map_food/features/store/data/models/store_dto.dart';

/// Busca textual de lojas, feita inteiramente no cliente.
///
/// Vive fora do widget pelo mesmo motivo do `lojasDentroDoRaio`: é regra de
/// negócio, e dentro de um `State` só seria verificável abrindo o app e
/// digitando. Aqui é função pura — mesma entrada, mesma saída.
///
/// ## O problema que isto resolve
///
/// O filtro anterior era `nome.toLowerCase().contains(termo)`. Três falhas
/// concretas, todas silenciosas (a tela dizia "nenhum comércio encontrado"):
///
/// 1. **Acento.** Quem digita "acai" no teclado do celular — sem parar para
///    achar o ç e o í — não encontrava "Açaí da Praça".
/// 2. **Só o nome.** Procurar "pastel" não achava nada, mesmo com lojas da
///    categoria Salgados chamadas "Dona Maria".
/// 3. **Um dedo errado.** "padria" não achava "Padaria", e a pessoa concluía
///    que não havia padaria por perto.
///
/// A busca da API (`GET /lojas/nome`) tem exatamente as mesmas limitações e é
/// `LIKE %termo%` no banco — daí resolver aqui, sobre a lista que o app já
/// mantém em memória.
List<StoreDto> buscarLojas(List<StoreDto> lojas, String termo) {
  final alvo = normalizarTexto(termo);
  if (alvo.isEmpty) return lojas;

  // O índice original entra no par para desempatar: `List.sort` do Dart não é
  // estável, e sem isso lojas de mesma relevância trocariam de posição a cada
  // tecla digitada — a lista "tremeria" enquanto a pessoa escreve.
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

/// Quão bem [loja] responde a [alvo] (já normalizado). Menor é melhor;
/// `null` significa "não é resultado".
///
/// A escala não é uma nota arbitrária: é a ordem em que uma pessoa espera ver
/// os resultados. Quem digita "pa" quer "Padaria Central" antes de uma loja
/// cuja *descrição* menciona "pão", e ambas antes de um acerto aproximado.
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

  // Último recurso: erro de digitação. Fica no fim da lista de propósito —
  // é um palpite, não um acerto.
  if (_pareceErroDeDigitacao(nome, alvo)) return 7;

  return null;
}

/// "pad" acha "Empório Padaria" na segunda palavra, não só no começo do nome.
bool _contemPalavraQueComecaCom(String texto, String alvo) {
  for (final palavra in texto.split(' ')) {
    if (palavra.startsWith(alvo)) return true;
  }
  return false;
}

/// `true` quando [alvo] parece uma versão errada de alguma palavra de [nome].
///
/// O limiar cresce com o tamanho do termo, e termos curtos não entram: com
/// distância 1 sobre 3 letras, "bar" acharia "mar", "lar" e "par" — uma busca
/// que devolve qualquer coisa é pior do que uma que não devolve nada.
bool _pareceErroDeDigitacao(String nome, String alvo) {
  if (alvo.length < 4) return false;
  final limite = alvo.length >= 7 ? 2 : 1;

  for (final palavra in nome.split(' ')) {
    if (palavra.length < 3) continue;
    // Compara só o trecho do tamanho do termo: sem isto, "padria" nunca casaria
    // com "padarias" pela diferença de comprimento.
    final trecho = palavra.length > alvo.length + limite
        ? palavra.substring(0, alvo.length + limite)
        : palavra;
    if (_distanciaLevenshtein(trecho, alvo) <= limite) return true;
  }
  return false;
}

/// Minúsculas e sem diacríticos.
///
/// Feito à mão em vez de por pacote: são 20 caracteres que importam em
/// português, e a alternativa (`unorm`/`diacritic`) traria uma dependência
/// inteira para isso.
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

/// Quantas edições (inserir, remover, trocar) separam duas palavras.
///
/// Duas linhas em vez da matriz inteira: a busca roda a cada tecla, sobre a
/// lista completa de lojas ativas.
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
