import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/carrinho.dart';
import 'ui/cadastro_page.dart';
import 'ui/checkout_page.dart';
import 'ui/widgets/home.dart';
import 'ui/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Carrinho(),
      child: const SMHotelApp(),
    ),
  );
}

class SMHotelApp extends StatelessWidget {
  const SMHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF0A5CAD);

    return MaterialApp(
      title: 'S&M Hotel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: azul),
        scaffoldBackgroundColor: const Color(0xFFF2F5FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: azul,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/cadastro': (_) => const CadastroPage(),
        '/home': (_) => const Home(),
        '/checkout': (_) => const CheckoutPage(),
      },
    );
  }
}