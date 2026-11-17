import 'package:flutter/foundation.dart';
import '../model/carrinho.dart';

class CarrinhoProvider extends ChangeNotifier {
  final List<Carrinho> _itens = [];

  List<Carrinho> get itens => List.unmodifiable(_itens);
  int get quantidade => _itens.length;
  bool get vazio => _itens.isEmpty;
  int get subtotal => _itens.fold(0, (soma, i) => soma + i.total);

  bool contem(String nome) => _itens.any((i) => i.nome == nome);

  /// Pix = 10% de desconto sobre o total da viagem.
  int desconto(FormaPagamento forma) =>
      forma == FormaPagamento.pix ? (subtotal * 0.10).round() : 0;

  int totalFinal(FormaPagamento forma) => subtotal - desconto(forma);

  /// Adiciona ou atualiza (um item por destino).
  void adicionar(Carrinho item) {
    final i = _itens.indexWhere((e) => e.nome == item.nome);
    if (i >= 0) {
      _itens[i] = item;
    } else {
      _itens.add(item);
    }
    notifyListeners();
  }

  void remover(String nome) {
    _itens.removeWhere((e) => e.nome == nome);
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }
}