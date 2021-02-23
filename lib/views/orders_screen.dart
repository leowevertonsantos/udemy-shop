import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_widget.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Consumer<Orders>(
            builder: (ctx, oerdersProvider, _) {
              return ListView.builder(
                itemCount: oerdersProvider.itemsCount,
                itemBuilder: (ctx, index) {
                  return OrderWidget(
                    order: oerdersProvider?.orders[index],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
