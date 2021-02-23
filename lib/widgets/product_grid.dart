import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.provider.dart';
import 'package:shop/widgets/product_grid_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavoriteOnly;

  const ProductsGrid({Key key, this.showFavoriteOnly}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final ProductsProvider productsProvider =
        Provider.of<ProductsProvider>(context);

    final List<Product> products = this.showFavoriteOnly
        ? productsProvider.favoriteItems
        : productsProvider.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: products[index],
          // create: (context) => products[index],
          child: ProductGridItem(),
        );
      },
    );
  }
}
