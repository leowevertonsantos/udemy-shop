import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.provider.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/product_item.dart';

class ProductsScreen extends StatelessWidget {
  @override
  Future<void> _refreshProducts(BuildContext context) {
    return Provider.of<ProductsProvider>(context, listen: false).loadProducts();
  }

  Widget build(BuildContext context) {
    ProductsProvider productsProvider = Provider.of(context);
    final List<Product> products = productsProvider?.items;
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PRODUCT_FORM);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsProvider.itemsCount,
            itemBuilder: (context, index) {
              return Column(children: [
                ProductItem(product: products[index]),
                Divider(),
              ]);
            },
          ),
        ),
      ),
    );
  }
}
