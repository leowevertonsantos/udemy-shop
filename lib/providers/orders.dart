import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as httpClient;
import 'package:shop/providers/cart.dart';
import 'package:shop/utils/constants.dart';

class Order {
  final String id;
  final double total;
  final List<CartItem> products;
  final DateTime date;

  Order({
    @required this.id,
    @required this.total,
    @required this.products,
    @required this.date,
  });
}

class Orders with ChangeNotifier {
  final _baseUrl = '${Constants.BASE_URL}/orders.json';

  List<Order> _orders = [];
  List<Order> get orders => [..._orders];
  int get itemsCount => _orders.length;

  Future<void> addOrer(List<CartItem> products, double total) async {
    final response = await httpClient.post(
      _baseUrl,
      body: json.encode({
        "total": total,
        "date": DateTime.now().toIso8601String(),
        "products": products
            .map((prodCart) => {
                  "id": prodCart.id,
                  "productId": prodCart.productId,
                  "title": prodCart.title,
                  "quantity": prodCart.quantity,
                  "price": prodCart.price,
                })
            .toList(),
      }),
    );

    if (response.statusCode >= 400) {
    } else {
      Order order = new Order(
        id: json.decode(response.body)["name"],
        total: total,
        products: products,
        date: DateTime.now(),
      );

      _orders.add(order);
      notifyListeners();
    }

    Future.value();
  }

  Future<void> loadOrders() async {
    List<Order> loadedItems = [];
    final response = await httpClient.get(_baseUrl);

    Map<String, dynamic> ordersMap = json.decode(response.body);

    ordersMap?.forEach((id, orderMap) {
      loadedItems.add(Order(
        id: id,
        total: orderMap['total'],
        date: DateTime.parse(orderMap['date']),
        products: (orderMap['products'] as List<dynamic>).map((productData) {
          return CartItem(
              id: productData['id'],
              productId: productData['productId'],
              title: productData['title'],
              quantity: productData['quantity'],
              price: productData['price']);
        }).toList(),
      ));
    });
    _orders = loadedItems.reversed.toList();
    notifyListeners();
    Future.value();
  }
}
