import 'package:appaula04/ui/_core/app_colors.dart';
import 'package:appaula04/ui/widgets/restaurant/categories/bebidascreen.dart';
import 'package:flutter/material.dart';

class CategoryWidget extends StatelessWidget {
  final String category;
  
  const CategoryWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (category.toLowerCase() == 'bebidas') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BebidaScreen(categoria: 'Bebidas'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoria $category em breve!'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightBackgroundColor,
        foregroundColor: Colors.black,
        fixedSize: const Size(100, 100),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.zero, 
      ),
      child: Column(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/categories/${category.toLowerCase()}.png',
            height: 48,
          ),
          Text(
            category,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}