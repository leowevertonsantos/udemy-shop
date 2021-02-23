import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/product.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart extends ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount => _items.length;

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(product.id, (existentItem) {
        return CartItem(
            id: existentItem.id,
            productId: product.id,
            price: existentItem.price,
            quantity: existentItem.quantity + 1,
            title: existentItem.title);
      });
    } else {
      _items.putIfAbsent(
          product.id,
          () => CartItem(
              id: Random().nextDouble().toString(),
              productId: product.id,
              price: product.price,
              quantity: 1,
              title: product.title));
    }

    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId].quantity == 1) {
      _items.remove(productId);
    } else {
      _items.update(productId, (existentItem) {
        return CartItem(
            id: existentItem.id,
            productId: productId,
            price: existentItem.price,
            quantity: existentItem.quantity - 1,
            title: existentItem.title);
      });
    }

    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearItems() {
    this._items = {};
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;

    items.forEach((key, item) {
      total += item.quantity * item.price;
    });

    return total;
  }
}
