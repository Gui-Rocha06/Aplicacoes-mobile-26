import 'package:flutter/material.dart';

enum FormaPagamento { pix, credito, debito }

extension FormaPagamentoX on FormaPagamento {
  String get label => switch (this) {
        FormaPagamento.pix => 'Pix',
        FormaPagamento.credito => 'Cartão de crédito',
        FormaPagamento.debito => 'Cartão de débito',
      };

  String get info => switch (this) {
        FormaPagamento.pix => '10% de desconto no total',
        FormaPagamento.credito => 'Pague na fatura',
        FormaPagamento.debito => 'Débito em conta',
      };

  IconData get icone => switch (this) {
        FormaPagamento.pix => Icons.qr_code_2,
        FormaPagamento.credito => Icons.credit_card,
        FormaPagamento.debito => Icons.account_balance_wallet_outlined,
      };
}

/// Item do carrinho = uma hospedagem já calculada.
class Carrinho {
  final String nome;
  final String img;
  final int dias;
  final int pessoas;
  final int total;

  const Carrinho({
    required this.nome,
    required this.img,
    required this.dias,
    required this.pessoas,
    required this.total,
  });
}