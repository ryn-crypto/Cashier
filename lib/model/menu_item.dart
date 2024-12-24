import 'dart:convert';

class MenuItem {
  final String name;
  final int price;
  final String category;
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'],
      price: json['price'],
      category: json['category'],
      imageUrl: json['image_url'],
    );
  }
}

List<MenuItem> parseMenu(String jsonData) {
  final data = jsonDecode(jsonData)['menu'];
  return List<MenuItem>.from(data.map((item) => MenuItem.fromJson(item)));
}
