import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../widgets/badge.dart';
import '../widgets/product_grid.dart';
import './cart_screen.dart';

enum FilterOptions { Favorites, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  // @override
  // void initState() {
  //   try {
  //     Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  //   } catch (e) {
  //     print(e);
  //   }
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      try {
        setState(() {
          _isLoading = true;
        });
        Provider.of<Products>(context).fetchAndSetProducts().then((_) => {
              setState(() {
                _isLoading = false;
              })
            });
      } catch (e) {
        print(e);
      }
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: ProductGrid(_showOnlyFavorites)),
      appBar: AppBar(
        title: const Text("My Shop"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, child) =>
                Badge(child: child, value: cart.itemCount.toString()),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
    );
  }
}
