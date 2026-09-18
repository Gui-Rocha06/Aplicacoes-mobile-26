import 'dart:convert';
import 'package:appaula04/model/dish.dart';
import 'package:appaula04/ui/_core/app_colors.dart';
import 'package:appaula04/ui/_core/appbar.dart';
import 'package:appaula04/ui/widgets/bag_provider.dart';
import 'package:appaula04/ui/widgets/checkout/checkout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BebidaItem {
  final Dish dish;
  final String restaurantName;
  final String restaurantImage;

  BebidaItem({
    required this.dish,
    required this.restaurantName,
    required this.restaurantImage,
  });
}

class BebidaScreen extends StatefulWidget {
  final String categoria;

  const BebidaScreen({super.key, required this.categoria});

  @override
  State<BebidaScreen> createState() => _BebidaScreenState();
}

class _BebidaScreenState extends State<BebidaScreen> {
  late Future<List<BebidaItem>> _bebidasFuture;

  @override
  void initState() {
    super.initState();
    _bebidasFuture = _loadBebidas();
  }

  // Carrega as bebidas da categoria Bebidas diretamente do json
  Future<List<BebidaItem>> _loadBebidas() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> restaurants = data['restaurants'] ?? [];
      final List<BebidaItem> bebidas = [];

      for (var restaurant in restaurants) {
        final String restaurantName = restaurant['name'] ?? '';
        final String restaurantImage = restaurant['imagePath'] ?? '';
        final List<dynamic> dishes = restaurant['dishes'] ?? [];

        for (var dishMap in dishes) {
          final String? category = dishMap['category'];
          if (category != null &&
              category.toLowerCase() == widget.categoria.toLowerCase()) {
            bebidas.add(
              BebidaItem(
                dish: Dish.fromMap(dishMap),
                restaurantName: restaurantName,
                restaurantImage: restaurantImage,
              ),
            );
          }
        }
      }

      return bebidas;
    } catch (e) {
      debugPrint('Erro ao carregar bebidas do json: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    BagProvider bagProvider = Provider.of<BagProvider>(context);

    // Calcula o total dos itens na sacola
    double totalBag = 0;
    for (Dish dish in bagProvider.dishesOnBag) {
      totalBag += dish.price;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: getAppBar(context: context, title: widget.categoria),
      body: FutureBuilder<List<BebidaItem>>(
        future: _bebidasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.mainColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar itens da categoria ${widget.categoria}.',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          final List<BebidaItem> bebidas = snapshot.data ?? [];

          if (bebidas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/categories/bebidas.png',
                    height: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma bebida encontrada.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabeçalho da Categoria
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.fundoCards,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/categories/bebidas.png',
                      height: 56,
                      width: 56,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoria,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Selecione as bebidas que deseja adicionar ao seu pedido',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Bebidas disponíveis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Lista de bebidas do json
              ...bebidas.map((item) {
                final int count = bagProvider.dishesOnBag
                    .where((d) => d.id == item.dish.id)
                    .length;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fundoCards,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Imagem da bebida com fallback
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/${item.dish.imagePath}',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/dishes/default.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Informações da bebida
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.dish.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.restaurantName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.mainColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.dish.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'R\$ ${item.dish.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Controles para selecionar e adicionar no bag_provider
                      if (count == 0)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            bagProvider.addAllDishes([item.dish]);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item.dish.name} adicionado à sacola!',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Adicionar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.mainColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: AppColors.mainColor,
                                ),
                                onPressed: () {
                                  bagProvider.removeDish(item.dish);
                                },
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  size: 18,
                                  color: AppColors.mainColor,
                                ),
                                onPressed: () {
                                  bagProvider.addAllDishes([item.dish]);
                                },
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),

      // Barra inferior com atalho para a sacola se houver itens
      bottomNavigationBar: bagProvider.dishesOnBag.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.fundoCards,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.shopping_basket,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ver Sacola (${bagProvider.dishesOnBag.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          'R\$ ${totalBag.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}