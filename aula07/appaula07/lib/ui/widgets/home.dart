import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/destinos_data.dart';
import '../../model/carrinho.dart';
import '../destino.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final nome = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_rounded),
            SizedBox(width: 8),
            Text('S&M Hotel',
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .5)),
          ],
        ),
        actions: [
          Consumer<Carrinho>(
            builder: (_, carrinho, __) => IconButton(
              tooltip: 'Carrinho',
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              icon: Badge(
                label: Text('${carrinho.quantidade}'),
                isLabelVisible: carrinho.quantidade > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<Carrinho>().limpar();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Cabeçalho de boas-vindas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0A5CAD), Color(0xFF29B6F6)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome == null ? 'Olá! 👋' : 'Olá, $nome! 👋',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Escolha seus destinos, monte a viagem e pague no Pix com 10% de desconto.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ListView com cada destino
          ...destinos.map(
            (d) => Destino(
              d.nome,
              d.img,
              d.valorDiaria,
              d.valorPessoa,
              key: ValueKey(d.nome),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<Carrinho>(
        builder: (_, carrinho, __) {
          if (carrinho.vazio) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, '/checkout'),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: Text(
                'Finalizar • ${real(carrinho.subtotal)} (${carrinho.quantidade})'),
          );
        },
      ),
    );
  }
}