import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/auth_service.dart';
import '../../../data/carrinho_provider.dart';
import '../../../model/destino_model.dart';
import '../../_core/app_colors.dart';
import '../../_core/app_theme.dart';
import 'checkout_page.dart';
import '../destino.dart';
import '../login/login_page.dart';

class Home extends StatelessWidget {
  final String? nomeUsuario;
  const Home({super.key, this.nomeUsuario});

  void _abrirCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutPage()),
    );
  }

  void _sair(BuildContext context) {
    AuthService.deslogar();
    context.read<CarrinhoProvider>().limpar();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeExibido =
        AuthService.usuarioAtual?['nome'] ?? nomeUsuario ?? 'Visitante';
    final primeiroNome = (nomeExibido as String).trim().split(' ').first;
    final isVisitante = !AuthService.isAutenticado;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel, size: 22),
            SizedBox(width: 8),
            Text('S&M Hotel'),
          ],
        ),
        actions: [
          Consumer<CarrinhoProvider>(
            builder: (context, carrinho, child) => IconButton(
              tooltip: 'Carrinho',
              onPressed: () => _abrirCheckout(context),
              icon: Badge(
                isLabelVisible: carrinho.quantidade > 0,
                label: Text('${carrinho.quantidade}'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
          ),
          if (isVisitante)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () async {
                final logou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(retornarAoCheckout: true),
                  ),
                );
                if (logou == true && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Home(
                        nomeUsuario:
                            AuthService.usuarioAtual?['nome'] as String?,
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Entrar'),
            )
          else
            IconButton(
              tooltip: 'Sair',
              onPressed: () => _sair(context),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVisitante || primeiroNome.isEmpty
                      ? 'Olá, Visitante!'
                      : 'Olá, $primeiroNome!',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Para onde vamos viajar?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...DestinoModel.destinos.map(
            (d) => Destino(d.nome, d.img, d.valord, d.valorp),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<CarrinhoProvider>(
        builder: (context, carrinho, child) => carrinho.vazio
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                onPressed: () => _abrirCheckout(context),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text('Finalizar • ${reais(carrinho.subtotal)}'),
              ),
      ),
    );
  }
}
