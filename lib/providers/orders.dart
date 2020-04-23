import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders => List.from(_orders);

  Future<void> fetchAndSetOrders() async {
    const url = 'https://flutter-shop-594fc.firebaseio.com/orders.json';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']))
              .toList()));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    const url = 'https://flutter-shop-594fc.firebaseio.com/orders.json';
    final timeStamp = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProduct
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          }));

      _orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProduct,
          ));
      notifyListeners();
    } catch (e) {
      throw e;
    }

    // _orders.insert(
    //     0,
    //     OrderItem(
    //       id: DateTime.now().toString(),
    //       amount: total,
    //       dateTime: DateTime.now(),
    //       products: cartProduct,
    //     ));
    // notifyListeners();
  }
}
