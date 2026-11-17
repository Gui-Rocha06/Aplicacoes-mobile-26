import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/auth_service.dart';
import '../../../data/carrinho_provider.dart';
import '../../../model/carrinho.dart';
import '../../_core/app_colors.dart';
import '../../_core/app_theme.dart';
import '../login/login_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  FormaPagamento _forma = FormaPagamento.pix;

  void _solicitarLogin() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.lock_person_outlined, color: AppColors.accent, size: 56),
        title: const Text('Login obrigatório', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Visitantes não podem finalizar a reserva no carrinho sem fazer login.\n\nPor favor, entre com sua conta ou cadastre-se para confirmar seu pedido.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Voltar ao carrinho'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final logou = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(retornarAoCheckout: true),
                ),
              );
              if (logou == true && mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Logado como ${AuthService.usuarioAtual?['nome']}! Agora você pode finalizar a reserva.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Fazer Login'),
          ),
        ],
      ),
    );
  }

  void _finalizar(CarrinhoProvider carrinho) {
    // Garante que o visitante não consiga finalizar o pedido sem logar
    if (!AuthService.isAutenticado) {
      _solicitarLogin();
      return;
    }

    final total = carrinho.totalFinal(_forma);
    final nomeCliente = AuthService.usuarioAtual?['nome'] ?? 'Cliente';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 64),
        title: const Text('Reserva confirmada!'),
        content: Text(
          'Reserva de $nomeCliente confirmada!\nPagamento via ${_forma.label}\nTotal: ${reais(total)}',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).popUntil((r) => r.isFirst);
              carrinho.limpar();
            },
            child: const Text('Voltar ao início'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrinho = context.watch<CarrinhoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: carrinho.vazio
          ? _vazio()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!AuthService.isAutenticado)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFEEBA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            color: Color(0xFF856404), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Você está como visitante. Faça login para finalizar a sua reserva.',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final logou = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginPage(retornarAoCheckout: true),
                              ),
                            );
                            if (logou == true && mounted) {
                              setState(() {});
                            }
                          },
                          child: const Text('Entrar'),
                        ),
                      ],
                    ),
                  ),
                _titulo('Seu pedido'),
                ...carrinho.itens.map((i) => _itemTile(i, carrinho)),
                const SizedBox(height: 20),
                _titulo('Forma de pagamento'),
                ...FormaPagamento.values.map(_pagamentoTile),
                const SizedBox(height: 20),
                _titulo('Resumo'),
                _resumo(carrinho),
                const SizedBox(height: 12),
              ],
            ),
      bottomNavigationBar: carrinho.vazio
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 12,
                        offset: Offset(0, -4)),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                        Text(
                          reais(carrinho.totalFinal(_forma)),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _finalizar(carrinho),
                        icon: Icon(
                          AuthService.isAutenticado
                              ? Icons.check_circle_outline
                              : Icons.lock_outline,
                          size: 18,
                        ),
                        label: Text(
                          AuthService.isAutenticado
                              ? 'Finalizar reserva'
                              : 'Entrar para finalizar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _vazio() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('Seu carrinho está vazio',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          SizedBox(height: 4),
          Text('Escolha um destino e toque em Calcular.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(texto,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      );

  Widget _itemTile(Carrinho i, CarrinhoProvider carrinho) {
    final dias = '${i.dias} ${i.dias == 1 ? 'diária' : 'diárias'}';
    final pessoas = '${i.pessoas} ${i.pessoas == 1 ? 'pessoa' : 'pessoas'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                Image.asset(i.img, width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.nome,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('$dias · $pessoas',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 4),
                Text(reais(i.total),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remover',
            onPressed: () => carrinho.remover(i.nome),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _pagamentoTile(FormaPagamento f) {
    final selecionado = _forma == f;
    return GestureDetector(
      onTap: () => setState(() => _forma = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.highlight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selecionado ? AppColors.primary : AppColors.border,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(f.icone, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(f.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      if (f == FormaPagamento.pix) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('-10%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ],
                  ),
                  Text(f.info,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12.5)),
                ],
              ),
            ),
            Icon(
              selecionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selecionado ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _resumo(CarrinhoProvider c) {
    final desconto = c.desconto(_forma);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          _linha('Subtotal', reais(c.subtotal)),
          if (desconto > 0) ...[
            const SizedBox(height: 8),
            _linha('Desconto Pix (10%)', '- ${reais(desconto)}',
                cor: AppColors.success),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _linha('Total', reais(c.totalFinal(_forma)), destaque: true),
        ],
      ),
    );
  }

  Widget _linha(String rotulo, String valor,
      {bool destaque = false, Color? cor}) {
    final estilo = TextStyle(
      fontSize: destaque ? 18 : 15,
      fontWeight: destaque ? FontWeight.w800 : FontWeight.w500,
      color: cor ?? AppColors.textDark,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(rotulo, style: estilo), Text(valor, style: estilo)],
    );
  }
}
