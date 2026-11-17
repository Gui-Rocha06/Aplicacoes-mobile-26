import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/carrinho_provider.dart';
import 'ui/_core/app_theme.dart';
import 'ui/widgets/login/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CarrinhoProvider(),
      child: const SMHotelApp(),
    ),
  );
}

class SMHotelApp extends StatelessWidget {
  const SMHotelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S&M Hotel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}