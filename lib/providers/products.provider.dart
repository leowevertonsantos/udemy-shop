import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as httpClient;
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/utils/constants.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  final _baseUrl = '${Constants.BASE_URL}/products';

  Future<void> addProduct(Product newProduct) {
    return httpClient
        .post(
      '$_baseUrl.json',
      body: json.encode(
        {
          "title": newProduct.title,
          "description": newProduct.description,
          "price": newProduct.price,
          "imageUrl": newProduct.imageUrl,
          "isFavorite": newProduct.isFavorite
        },
      ),
    )
        .then((response) {
      this._items.add(Product(
            id: json.decode(response.body)['name'],
            title: newProduct.title,
            description: newProduct.description,
            price: newProduct.price,
            imageUrl: newProduct.imageUrl,
          ));
      notifyListeners();
    });
  }

  Future<void> loadProducts() async {
    final response = await httpClient.get('$_baseUrl.json');
    Map<String, dynamic> data = json.decode(response.body);

    _items.clear();
    data?.forEach((productId, productData) {
      _items.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorite']));
    });
    notifyListeners();
    return Future.value();
  }

  Future<void> updaeProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    final int index = _items.indexWhere((produc) => produc.id == product.id);
    if (index >= 0) {
      await httpClient.patch('$_baseUrl/${product.id}.json',
          body: json.encode(
            {
              "title": product.title,
              "description": product.description,
              "price": product.price,
              "imageUrl": product.imageUrl,
            },
          ));
      _items[index] = product;
    }

    notifyListeners();
  }

  Future<void> deleteProduct(String productId) async {
    // Product product = _items.firstWhere((prodc) => prodc.id == productId);
    final index = _items.indexWhere((prodc) => prodc.id == productId);
    Product product = _items[index];

    if (null != product) {
      _items.remove(product);
      notifyListeners();

      final response = await httpClient.delete('$_baseUrl/$productId.json');

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();

        throw HttpException(msg: 'Erro ao excluir o produto');
      }
    }

    return Future.value();
  }

  int get itemsCount => _items.length;

  List<Product> get items => [..._items];

  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();
}
