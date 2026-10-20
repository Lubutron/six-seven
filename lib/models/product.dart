class Product {
  const Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating = 0,
    this.ratingCount = 0,
  });

  final int? id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    final rating = rawRating is Map<String, dynamic> ? rawRating : null;
    final idValue = json['id'];

    return Product(
      id: idValue is int ? idValue : int.tryParse('$idValue'),
      title: json['title'] as String? ?? '',
      price: _toDouble(json['price']),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: _toDouble(rating?['rate']),
      ratingCount: _toInt(rating?['count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'price': price,
    'description': description,
    'category': category,
    'image': image,
  };

  Product copyWith({int? id}) => Product(
    id: id ?? this.id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
    rating: rating,
    ratingCount: ratingCount,
  );

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
