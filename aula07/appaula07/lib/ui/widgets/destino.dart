import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/carrinho_provider.dart';
import '../../model/carrinho.dart';
import '../_core/app_colors.dart';
import '../_core/app_theme.dart';

class Destino extends StatefulWidget {
  final String nome;
  final String img;
  final int valord;
  final int valorp;

  const Destino(
    this.nome,
    this.img,
    this.valord,
    this.valorp, {
    super.key,
  });

  @override
  State<Destino> createState() => _DestinoState();
}

class _DestinoState extends State<Destino> {
  // ignore: non_constant_identifier_names
  int n_diarias = 0;
  // ignore: non_constant_identifier_names
  int n_pessoas = 0;
  int total = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final carrinho = context.read<CarrinhoProvider>();
      final item = carrinho.itens.where((e) => e.nome == widget.nome).firstOrNull;
      if (item != null) {
        setState(() {
          n_diarias = item.dias;
          n_pessoas = item.pessoas;
          total = item.total;
        });
      }
    });
  }

  void dias() {
    setState(() {
      n_diarias++;
    });
  }

  void diminuirDias() {
    if (n_diarias > 0) {
      setState(() {
        n_diarias--;
      });
    }
  }

  void pessoas() {
    setState(() {
      n_pessoas++;
    });
  }

  void diminuirPessoas() {
    if (n_pessoas > 0) {
      setState(() {
        n_pessoas--;
      });
    }
  }

  void calctotal() {
    setState(() {
      total = (n_diarias * widget.valord) + (n_pessoas * widget.valorp);
    });

    if (total > 0) {
      context.read<CarrinhoProvider>().adicionar(
            Carrinho(
              nome: widget.nome,
              img: widget.img,
              dias: n_diarias,
              pessoas: n_pessoas,
              total: total,
            ),
          );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.nome} adicionado ao carrinho!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos 1 diária ou pessoa para calcular'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void limpar() {
    setState(() {
      n_diarias = 0;
      n_pessoas = 0;
      total = 0;
    });
    context.read<CarrinhoProvider>().remover(widget.nome);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Valores de ${widget.nome} limpos!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagem do destino (393 x 250)
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Image.asset(
              widget.img,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome do destino
                Text(
                  widget.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),

                // Preços
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.highlight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Diária: ${reais(widget.valord)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pessoa: ${reais(widget.valorp)}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Botão 1: Dias de hospedagem
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dias de hospedagem:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          onPressed: diminuirDias,
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '$n_diarias',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          onPressed: dias,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Botão 2: Acompanhantes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Número de acompanhantes:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          onPressed: diminuirPessoas,
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            '$n_pessoas',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        IconButton.filled(
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          onPressed: pessoas,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Valor total calculado
                if (total > 0) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.highlight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total da viagem:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          reais(total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Botões 3 e 4: Calcular e Limpar
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: calctotal,
                        icon: const Icon(Icons.calculate_outlined, size: 20),
                        label: const Text('Calcular'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        onPressed: limpar,
                        icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                        label: const Text('Limpar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
