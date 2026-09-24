import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importe seus arquivos separados (ajuste os caminhos conforme suas pastas)
import 'ui/_core/app_colors.dart'; // Onde está o seu AppTheme
import 'ui/login/login_page.dart';
import 'data/carrinho_provider.dart';

void main() {
  runApp(
    // O MultiProvider envolve o app para que o Carrinho possa ser acessado 
    // de qualquer tela, como exigido pelo projeto para calcular o total.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CarrinhoProvider()),
      ],
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S&M Hotel',
      debugShowCheckedModeBanner: false,
      // Aqui você aplica o tema que você criou!
      theme: AppTheme.appTheme, 
      // Define a tela de Login como a tela inicial
      home: const LoginPage(), 
    );
  }
}