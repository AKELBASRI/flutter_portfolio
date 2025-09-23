import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Wireless Headphones',
      description: 'High-quality wireless headphones with noise cancellation and superior sound quality.',
      price: 199.99,
      imageUrl: '🎧',
      category: 'Electronics',
      rating: 4.5,
      reviews: 128,
    ),
    Product(
      id: '2',
      name: 'Smart Watch',
      description: 'Feature-rich smartwatch with fitness tracking, notifications, and long battery life.',
      price: 299.99,
      imageUrl: '⌚',
      category: 'Electronics',
      rating: 4.7,
      reviews: 89,
    ),
    Product(
      id: '3',
      name: 'Coffee Maker',
      description: 'Premium coffee maker with programmable settings and thermal carafe.',
      price: 149.99,
      imageUrl: '☕',
      category: 'Kitchen',
      rating: 4.3,
      reviews: 67,
    ),
    Product(
      id: '4',
      name: 'Running Shoes',
      description: 'Comfortable running shoes with excellent cushioning and breathable material.',
      price: 129.99,
      imageUrl: '👟',
      category: 'Sports',
      rating: 4.6,
      reviews: 156,
    ),
    Product(
      id: '5',
      name: 'Laptop Stand',
      description: 'Adjustable laptop stand for better ergonomics and improved airflow.',
      price: 49.99,
      imageUrl: '💻',
      category: 'Accessories',
      rating: 4.4,
      reviews: 92,
    ),
    Product(
      id: '6',
      name: 'Bluetooth Speaker',
      description: 'Portable Bluetooth speaker with rich bass and 12-hour battery life.',
      price: 79.99,
      imageUrl: '🔊',
      category: 'Electronics',
      rating: 4.2,
      reviews: 74,
    ),
  ];

  List<Product> get products => _products;

  Product getProductById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }
}