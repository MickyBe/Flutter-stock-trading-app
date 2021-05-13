import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tech_camp/common/fackdata.dart';
import 'package:flutter_tech_camp/src/cart/cubit/cart_cubit.dart';
import 'package:flutter_tech_camp/src/cart/models/cart.dart';
import 'package:flutter_tech_camp/src/cart/models/cart_item.dart';
import 'package:flutter_tech_camp/src/product_detail/screen/home_page_sceen.dart';

import '../../../injection_container.dart';
import '../../routes/router.gr.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'My Watch list',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            ExtendedNavigator.of(context).push(Routes.productsPage);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.black87,
        child: BlocProvider(
          create: (_) => sl<CartCubit>(),
          child: BlocBuilder<CartCubit, CartState>(builder: (context, state) {
            if (state is CartState) {
              return _Carts(
                cart: state.cart,
              );
            }
            return SizedBox();
          }),
        ),
      ),
    );
  }
}

class _Carts extends StatelessWidget {
  final Cart cart;

  const _Carts({Key key, this.cart}) : super(key: key);
  double roundDouble(double value, int places){
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
  double generator_price () {
    Random r1 = new Random();
    return roundDouble(r1.nextDouble()*200,3);
  }
  double generator_exchange () {
    Random r1 = new Random();
    return r1.nextBool()?roundDouble(r1.nextDouble()*3,3):roundDouble(r1.nextDouble()*-3,3);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(color: Colors.grey[400]);
      },
      itemCount: 5,
      itemBuilder: (context, index) {

        final stock = stocksdata[index];

        return ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageScreen(
                    product: stock,
                  ),
                ));
          },
          contentPadding: EdgeInsets.all(20),
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("${stock['name']}", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                Text("${stock['country']}",style: TextStyle(color: Colors.grey[500], fontSize: 20)),
              ]),
          trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("\$${generator_price()}", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
                Container(
                  width: 75,
                  height: 22,
                  child: Text("${generator_exchange()}%", style: TextStyle(color: Colors.white)),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: generator_exchange()>=0?Colors.green:Colors.red
                  ),
                )
              ]),
        );

      },
    );
  }
}

class _Cart extends StatelessWidget {
  final CartItem cartItem;

  const _Cart({Key key, this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network('ddd'),//cartItem.product['country']
        title: Text(
          'string',//cartItem.product['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildProductContainer(
                  '${cartItem.multiplier} x ${cartItem.multiplier}'),//${cartItem.product['symbol']}
            ),
            Row(
              children: [
                _buildTextButton(context, Icons.remove, false),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${cartItem.multiplier}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildTextButton(context, Icons.add, true)
              ],
            )
          ],
        ),
      ),
    );
  }

  TextButton _buildTextButton(
      BuildContext context, dynamic icon, bool isIncrementing) {
    return TextButton(
      onPressed: () {
        final cubit = context.read<CartCubit>();
        if (isIncrementing) {
          cubit.addToCart(cartItem.product);
        } else {
          cubit.removeFromCart(cartItem.product);
        }
      },
      child: Icon(icon),
    );
  }

  Container _buildProductContainer(String _productPrice) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(_productPrice, 15, false),
        ],
      ),
    );
  }

  Text _buildText(String _text, double _textSize, bool _isBold) {
    FontWeight _textBold;
    if (_isBold == true) {
      _textBold = FontWeight.bold;
    } else {
      _textBold = FontWeight.normal;
    }
    return Text(
      _text,
      style: TextStyle(fontSize: _textSize, fontWeight: _textBold),
    );
  }
}
