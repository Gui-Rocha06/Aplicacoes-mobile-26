// Criando a classe dish

class Dish {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imagePath;
  final String? category;

  // Cria o construtor

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.category,
  });

  // Metodo para tratar chave e valor

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'category': category,
    };
  }

  // Função para fazer a conversão de chave e valor

  factory Dish.fromMap(Map<String, dynamic> map) {
    return Dish(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      price: (map['price'] as num).toInt(),
      imagePath: map['imagePath'] ?? 'dishes/default.png',
      category: map['category'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dish && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Função para converter para String
  @override
  String toString() {
    return 'Dish(id:$id,name:$name,description:$description,price:$price, imagePath:$imagePath, category:$category)';
  }
}
