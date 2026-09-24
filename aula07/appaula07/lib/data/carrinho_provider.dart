import 'package:flutter/material.dart';

class CarrinhoProvider extends ChangeNotifier {
  int valorTotal = 0;

  void atualizarTotal(int novoTotal) {
    valorTotal = novoTotal;
    notifyListeners();
  }
}