import 'package:appaula07/ui/_core/app_colors.dart';
import 'package:flutter/material.dart';

// cria uma classe abstrata do tema do app

abstract class AppTheme {
  // Cria uma variavel para armazenar o tema do app
  // Função para copiar o tema do aplicativo

  static ThemeData appTheme = ThemeData.dark().copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.black),
              backgroundColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey;
                } else if (states.contains(WidgetState.pressed)) {
                  return Color.fromARGB(209, 255, 201, 158);
                }
                return AppColors.mainColor;
              }))));
}
