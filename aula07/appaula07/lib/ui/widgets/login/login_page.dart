import 'package:flutter/material.dart';

import '../../../data/auth_service.dart';
import '../../_core/app_colors.dart';
import '../pages/home.dart';
import 'cadastro_page.dart';

class LoginPage extends StatefulWidget {
  final bool retornarAoCheckout;
  const LoginPage({super.key, this.retornarAoCheckout = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _auth = AuthService();
  bool _carregando = false;
  bool _ocultar = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _msg(String texto, {bool erro = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: erro ? Colors.redAccent : AppColors.success,
      ));
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      final user = await _auth.login(_email.text.trim(), _senha.text);
      if (!mounted) return;
      if (user == null) {
        _msg('E-mail ou senha incorretos');
      } else {
        if (widget.retornarAoCheckout) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Home(nomeUsuario: user['nome'] as String?),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        _msg('Não foi possível conectar ao servidor.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _irParaCadastro() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroPage()),
    );
    if (ok == true && mounted) {
      _msg('Cadastro realizado! Faça seu login.', erro: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.retornarAoCheckout
          ? AppBar(
              title: const Text('Fazer Login'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, false),
              ),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hotel, size: 44, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'S&M Hotel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Planeje sua próxima viagem',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Form(
                      key: _form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Informe um e-mail válido'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _senha,
                            obscureText: _ocultar,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_ocultar
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _ocultar = !_ocultar),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Informe a senha' : null,
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton(
                            onPressed: _carregando ? null : _entrar,
                            child: _carregando
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.white),
                                  )
                                : const Text('Entrar'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _irParaCadastro,
                            child: const Text('Não tem conta? Cadastre-se'),
                          ),
                          if (!widget.retornarAoCheckout)
                            TextButton.icon(
                              onPressed: () {
                                AuthService.deslogar();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const Home(nomeUsuario: 'Visitante'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward, size: 16),
                              label: const Text('Entrar como visitante'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
