import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.provider.dart';
import 'package:shop/utils/app_routes.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          product.imageUrl,
        ),
        backgroundColor: Colors.transparent,
      ),
      title: Text(product.title),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Theme.of(context).errorColor,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                  arguments: product,
                );
              },
            ),
            IconButton(
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title:
                          Text('Deseja realmente excluir o produto abaixo ?'),
                      content: ListTile(
                        title: Text(product.title),
                        subtitle: Text(
                          product.description,
                        ),
                      ),
                      actions: [
                        FlatButton(
                            child: Text('Não'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            }),
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text('Sim'))
                      ],
                    );
                  },
                ).then((isConfirmed) async {
                  if (isConfirmed) {
                    try {
                      await Provider.of<ProductsProvider>(context,
                              listen: false)
                          .deleteProduct(product.id);
                      // productsProvider.deleteProduct(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Produto deletado com sucesso'),
                      ));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${error.toString()}'),
                      ));
                    }
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
