import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as httpClient;
import 'package:shop/utils/constants.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _togleFavoriteAndNotify() {
    this.isFavorite = !this.isFavorite;
    notifyListeners();
  }

  Future<void> togleFavorite() async {
    final url = '${Constants.BASE_URL}/products/$id.jsaon';

    this._togleFavoriteAndNotify();

    try {
      final response = await httpClient.patch(url,
          body: json.encode({"isFavorite": this.isFavorite}));

      if (response.statusCode >= 400) {
        this._togleFavoriteAndNotify();
      }
    } catch (e) {
      this._togleFavoriteAndNotify();
    }

    Future.value();
  }
}
